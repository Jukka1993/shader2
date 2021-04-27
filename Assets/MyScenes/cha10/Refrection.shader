// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/Refrection"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _ReflectColor("Reflection Color", Color) = (1,1,1,1)
        _ReflectAmount("Reflect Amount", Range(0,1)) = 100
        _CubeMap("Reflection CubeMap", Cube) = "_Skybox" {}
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
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float3 worldNormal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
                float3 worldViewDir:TEXCOORD2;
                float4 vertex : SV_POSITION;
                float3 worldRef1:TEXCOORD3;
            };

            float4 _Color;
            float4 _ReflectColor;
            float _ReflectAmount;
            samplerCUBE _CubeMap;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                //Compute the reflect dir in world space
                o.worldRef1 = reflect(-o.worldViewDir, o.worldNormal);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(i.worldViewDir);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _Color.rgb * _LightColor0.rgb * max(0,dot(worldNormal, worldLightDir));
                fixed3 reflection = texCUBE(_CubeMap, i.worldRef1).rgb * _ReflectColor.rgb;
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                fixed3 color = ambient + lerp(diffuse, reflection, _ReflectAmount) * atten;
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}
