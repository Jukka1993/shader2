// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/ForwardRendering"
{
    Properties
    {
        _Diffuse("diffuse", Color) = (1.0, 1.0, 1.0,1.0)
		_Specular("specular",Color) = (1.0, 1.0, 1.0, 1.0)
		_Gloss("gloss",Range(8, 256)) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
			Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM

			#pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
			#include "Lighting.cginc"

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
				
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
            };

            float _Gloss;
			float4 _Diffuse;
			float4 _Specular;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0).xyz;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//discard;

				fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * max(0,dot(worldLightDir, worldNormal));

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 halfDir = normalize(viewDir + worldLightDir);
				fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(max(0,dot(halfDir, worldNormal)),_Gloss);
				fixed3 atten = 1.0;
				return fixed4(ambient + (diffuse + specular) * atten, 1.0);
            }
            ENDCG
        }
		Pass{
			Tags{"LightMode" = "ForwardAdd"}
			Blend One One
			CGPROGRAM
			#pragma multi_compile_fwdadd
			#pragma vertex vert
            #pragma fragment frag
			#include "Lighting.cginc"

            #include "UnityCG.cginc"
			#include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
				
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
            };

            float _Gloss;
			float4 _Diffuse;
			float4 _Specular;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0).xyz;
				#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
				#endif

				fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * max(0,dot(worldLightDir, worldNormal));

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 halfDir = normalize(viewDir + worldLightDir);
				fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(max(0,dot(halfDir, worldNormal)),_Gloss);
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 atten = 1.0;
				#else
					float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
					fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				#endif
				return fixed4((diffuse + specular) * atten, 1.0);
            }


			ENDCG
		}
    }
}
