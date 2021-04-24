// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/SingleTexture"
{
    Properties
    {
        _Diffuse("diffuse", Color) = (1.0,1.0,1.0,1.0)
        _MainTex("Main Tex", 2D) = "white" {}
        _Gloss("gloss",Range(8, 256)) = 20
        _Specular("specular", Color) = (1.0,1.0,1.0,1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
                float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float4 worldPos:TEXCOORD1;
                float2 uv:TEXCOORD2;
            };

            float4 _Specular;
            float4 _Diffuse;
            float _Gloss;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0);

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Diffuse.rgb;

                fixed3 ambient = albedo * UNITY_LIGHTMODEL_AMBIENT;

                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));



                //fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;


                //fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * saturate(dot(worldNormal, worldLightDir));

                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 h = normalize(worldLightDir + viewDir);
                fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(worldNormal, h)), _Gloss);

                fixed3 col =  ambient + diffuse + specular;
                return fixed4(col, 1.0);
            }
            ENDCG
        }
    }
}
