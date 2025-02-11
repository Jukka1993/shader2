﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/SpecularVertextLevel"
{
	Properties{
		_Diffuse("Diffuse", Color) = (1,1,1,1)
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
	}
	SubShader{
		Pass{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};
			struct v2f {
				fixed4 pos:SV_POSITION;
				fixed3 color : COLOR;
			};
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;



				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				//fixed3 diffuse = saturate(dot(worldNormal, worldLight)) * _Diffuse.rgb * _LightColor0.rgb;
				fixed3  diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
				//o.color = specular + ambient;// +diffuse;
				o.color = diffuse + specular
					+ ambient;// +diffuse;
				return o;
			}
			fixed4 frag(v2f o):SV_Target{
				return fixed4(o.color, 1);
			}
			ENDCG
		}
		Pass {
			Name "ShadowCaster"
			Tags {"LightMode" = "ShadowCaster"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"
			struct v2f {
				V2F_SHADOW_CASTER;
			};
			v2f vert(appdata_base v){
				v2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}
			float4 frag(v2f i):SV_Target{
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}
	}
	//Fallback "VertexLit"
}