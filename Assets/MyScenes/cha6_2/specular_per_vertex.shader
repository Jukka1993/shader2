// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/specular_per_vertex"
{
    Properties
    {
        _Diffuse("diffuse",Color) = (1.0,1.0,1.0,1.0)
        _Gloss("gloss", Range(8,256)) = 20
        _Specular("specular", Color) = (1.0,1.0,1.0,1.0)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
     
            #include "Lighting.cginc"
            float4 _Diffuse;
            float _Gloss;
            float4 _Specular;
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                fixed3 color:COLOR;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;


                float3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz -  mul(unity_ObjectToWorld, v.vertex).xyz);

                fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(reflectDir,viewDir)),_Gloss);

                o.color = ambient + diffuse + specular;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color, 1);
            }
            ENDCG
        }
    }
}
