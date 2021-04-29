// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/diffuse_per_vertex" {
	Properties{
		_Color("diffuse Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	SubShader {
		Pass {
			CGPROGRAM
			#include "Lighting.cginc"
			#pragma vertex vert
			#pragma fragment frag
			fixed4 _Color;
			struct v2f {
				float4 pos:SV_POSITION;
				fixed4 color: TEXCOORD0;
			};
			v2f vert(appdata_base i) {
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldNormal = normalize(UnityObjectToWorldNormal(i.normal));
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(UnityObjectToClipPos(i.vertex).xyz));
				fixed3 diffuse = _Color.rgb * _LightColor0.rgb * max(0, dot(worldLightDir, worldNormal));
				
				o.color = fixed4(diffuse + ambient, 1.0);
				return o;
			}
			fixed4 frag(v2f i):SV_Target {
				return i.color;
			}
			ENDCG
		}
	}
}