// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/specular_per_vertex" {
	Properties {
		_Diffuse("diffuse", Color) = (1.0,1.0,1.0,1.0)
		_Specular("specular", Color) = (1.0,1.0,1.0,1.0)
		_Gloss("gloss",Range(8,256)) = 20
	}
	SubShader {
			
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			float4 _Diffuse;
			float4 _Specular;
			float _Gloss;
			struct v2f {
				float4 pos:SV_POSITION;
				float4 color:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
			};
			v2f vert(appdata_base i) {
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.worldPos = mul(unity_ObjectToWorld, i.vertex).xyz;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldNormal = normalize(UnityObjectToWorldNormal(i.normal));
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(o.worldPos));
				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));
				fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * max(0, dot(worldNormal, worldLightDir));
				fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(worldViewDir, reflectDir)),_Gloss);
				o.color = fixed4(ambient+diffuse + specular,1.0);
				return o;
			}
			fixed4 frag(v2f i):SV_Target{
				return i.color;
			}

			ENDCG
		}
	}

}