// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/SingleTexture" {
	Properties {
		_MainTex("MainTex", 2D) = "white"{}
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_Gloss("Gloss", Range(8, 256)) = 20
	}
	SubShader {
		
		Pass {
			CGPROGRAM
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float4 _Specular;
			float _Gloss;

			#pragma vertex vert
			#pragma fragment frag
			struct v2f {
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				float2 uv:TEXCOORD2;
			};
			v2f vert(appdata_base i) {
				v2f o;
				o.worldNormal = UnityObjectToWorldNormal(i.normal);
				o.worldPos = mul(unity_ObjectToWorld, i.vertex).xyz;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.uv = TRANSFORM_TEX(i.texcoord, _MainTex);

				return o;
			}
			fixed4 frag(v2f i):SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
				fixed3 albedo = _Color.rgb * tex2D(_MainTex, i.uv).xyz;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = albedo * _LightColor0.rgb * max(0, dot(worldNormal, worldLightDir));
				fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(reflectDir, worldViewDir)), _Gloss);

				return fixed4 (ambient + diffuse + specular, 1.0);

			}

			ENDCG
		}

	}
}