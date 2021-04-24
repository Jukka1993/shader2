Shader "Unlit/specular_per_fragment_blinn"
{
    Properties
    {
        _Diffuse("diffuse",Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss("gloss", Range(8,256)) = 20
        _Specular("specular", Color) = (1.0, 1.0, 1.0, 1.0)
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
            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 worldPos: TEXCOORD0;
                float3 worldNormal:TEXCOORD1;
                float4 vertex:SV_POSITION;
            };

            float4 _Diffuse;
            float4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 normal = normalize(i.worldNormal);

                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * saturate(dot(normal, lightDir));

                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

                fixed3 h = normalize(viewDir + lightDir);

                fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(h, normal)), _Gloss);

                fixed3 color = ambient + diffuse + specular;

                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
