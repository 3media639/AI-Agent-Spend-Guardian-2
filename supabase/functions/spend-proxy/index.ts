import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "*",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    // Extract SpendGuard User Key or Bearer Token
    const authHeader = req.headers.get("Authorization") ?? "";
    const spendguardKey = req.headers.get("X-SpendGuard-Key") ?? authHeader.replace("Bearer ", "");

    if (!spendguardKey) {
      return new Response(
        JSON.stringify({ error: "SpendGuard Authorization key required" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 1. Check if user is in EMERGENCY FREEZE
    const { data: freezeData } = await supabaseClient
      .from("freeze_states")
      .select("is_frozen, reason")
      .limit(1)
      .maybeSingle();

    if (freezeData?.is_frozen) {
      return new Response(
        JSON.stringify({
          error: {
            message: `[SpendGuard Kill-Switch Active]: ${freezeData.reason || "AI spending has been frozen."}`,
            type: "spendguard_emergency_freeze",
            code: 429,
          },
        }),
        {
          status: 429,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // 2. Parse request details
    const url = new URL(req.url);
    const targetPath = url.pathname.replace(/^\/spend-proxy/, "");
    const bodyText = await req.text();
    const parsedBody = bodyText ? JSON.parse(bodyText) : {};
    const model = parsedBody.model || "gpt-4o";

    // 3. Forward request to upstream provider (e.g. OpenAI)
    const upstreamUrl = `https://api.openai.com${targetPath}`;
    const upstreamResp = await fetch(upstreamUrl, {
      method: req.method,
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${Deno.env.get("OPENAI_API_KEY") || spendguardKey}`,
      },
      body: bodyText,
    });

    const responseData = await upstreamResp.text();

    // 4. Background token & cost recording (approximate pricing calculation)
    try {
      const respJson = JSON.parse(responseData);
      const usage = respJson.usage;
      if (usage) {
        // e.g. prompt $2.50/M tokens, completion $10.00/M tokens
        const cost = (usage.prompt_tokens * 0.0000025) + (usage.completion_tokens * 0.000010);
        // insert into spend_records asynchronously
      }
    } catch (_) {
      // Non-blocking for streaming or parsing quirks
    }

    return new Response(responseData, {
      status: upstreamResp.status,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
