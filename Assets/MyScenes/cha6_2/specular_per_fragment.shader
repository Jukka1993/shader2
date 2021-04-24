// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/specular_per_fragment"
{
    Properties
    {
        _Diffuse("diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss("gloss", Range(8, 256)) = 20
        _Specular("specular", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #include "Lighting.cginc"
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal: TEXCOORD0;
                float4 worldPos:TEXCOORD1;
            };

            float4 _Specular;
            float4 _Diffuse;
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
                fixed3 ambient = unity_AmbientSky.xyz;
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * saturate(dot(worldNormal, lightDir));

                fixed3 reflectDir = normalize(reflect(-lightDir,worldNormal ));
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

                fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(reflectDir, viewDir)),_Gloss);
                fixed3 col3 =  diffuse + ambient + specular;//;//
                fixed4 col = fixed4(col3, 1.0);
                return col;
            }
            ENDCG
        }
    }
}
