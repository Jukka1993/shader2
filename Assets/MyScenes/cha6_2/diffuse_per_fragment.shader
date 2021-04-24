// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/diffuse_per_fragment"{
	Properties{
		_Diffuse("diffuse",Color) = (1.0,1.0,1.0,1.0)
	}
	SubShader{
		Pass{
			CGPROGRAM
			#include "Lighting.cginc"
			#pragma vertex vert
			#pragma fragment frag
			float4 _Diffuse;
			struct a2v {
				float4 pos:POSITION;
				float3 normal:NORMAL;
			};
			struct v2f {
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
			};
			v2f vert(a2v i){
				v2f o;
				o.pos = UnityObjectToClipPos(i.pos);
				o.worldNormal = mul(i.normal, (float3x3)unity_WorldToObject);
				return o;
			}
			fixed4 frag(v2f i):SV_Target{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * saturate(dot(worldNormal, worldLightDir));

				fixed3 color = diffuse + ambient;
				return fixed4(color, 1.0);
			}
			ENDCG
		}
	}
	Fallback "diffuse"
}