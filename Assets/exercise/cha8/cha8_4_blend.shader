// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/cha8_4_blend"
{
    Properties
    {
        _MainTex223 ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _AlphaScale ("Alpha Scale", Range(0,1))= 1
    }
    SubShader
    {
        Tags {"Queue"= "Transparent"  "RenderType"="Transparent" }//"IgnoreProjector"="True"
        LOD 100

        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            //struct appdata
            //{
            //    float4 vertex : POSITION;
            //    float2 uv : TEXCOORD0;
            //};

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal:TEXCOORD1;
                float3 worldPos:TEXCOORD2;
            };

            sampler2D _MainTex223;
            float4 _MainTex223_ST;
            float _AlphaScale;
            float4 _Color;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex223);
                o.worldNormal = UnityObjectToWorldNormal(v.normal).xyz;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex223, i.uv);
                fixed3 albedo = _Color.rgb * col.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 diffuse = albedo * _LightColor0.rgb * max(0, dot(worldNormal, worldLightDir));
                return fixed4(ambient + diffuse, col.a * _AlphaScale);
            }
            ENDCG
        }
    }
    //Fallback "VertexLit"
}
