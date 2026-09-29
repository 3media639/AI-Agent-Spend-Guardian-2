import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
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

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing authorization header" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Verify user JWT
    const {
      data: { user },
      error: userError,
    } = await supabaseClient.auth.getUser(authHeader.replace("Bearer ", ""));
    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Invalid token" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { action, reason } = await req.json();
    const shouldFreeze = action === "freeze";

    // Update freeze state
    const { error: freezeError } = await supabaseClient
      .from("freeze_states")
      .upsert({
        user_id: user.id,
        is_frozen: shouldFreeze,
        frozen_at: shouldFreeze ? new Date().toISOString() : null,
        reason: shouldFreeze ? (reason ?? "Emergency Kill Switch Activated") : null,
        updated_at: new Date().toISOString(),
      });

    if (freezeError) throw freezeError;

    // Log alert event
    await supabaseClient.from("alert_logs").insert({
      user_id: user.id,
      severity: shouldFreeze ? "emergencyFreeze" : "info",
      title: shouldFreeze ? "Emergency Freeze Activated" : "Spending Resumed",
      message: shouldFreeze
        ? "All AI agent traffic via SpendGuard has been blocked."
        : "AI spending has been unblocked by user.",
      is_read: false,
    });

    return new Response(
      JSON.stringify({
        success: true,
        is_frozen: shouldFreeze,
        timestamp: new Date().toISOString(),
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});
