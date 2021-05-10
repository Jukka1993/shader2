Shader "Unlit/river" {
	Properties {
		_MainTex("mainTex", 2D) = "white" {}
		_Color("Color",Color) = (1.0, 1.0, 1.0, 1.0)
		_Magnitude("Distortion Magnitude", Float) = 1
		_Frequency("Distortion Frequency", Float) = 1
		_InvWaveLength("Distortion Inverse Wave Length", Float) = 10
		_Speed("Speed", Float) = 0.5
	}
	SubShader {
		Tags{"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "DisableBatching" = "True"}
		Pass {
			Tags{"LightMode"= "ForwardBase"}
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float _Magnitude;
			float _Frequency;
			float _InvWaveLength;
			float _Speed;

			struct v2f {
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
			};
			v2f vert(appdata_base i) {
				v2f o;
				float4 offset;
				offset.yzw = float3(0.0, 0.0, 0.0);
				//_Frequency * _Time.y + 
				//  i.vertex.x * _InvWaveLength + i.vertex.y * _InvWaveLength +   i.vertex.x * _InvWaveLength+
				offset.x = sin(_Frequency * _Time.y +  i.vertex.z * _InvWaveLength) * _Magnitude;
				o.pos = UnityObjectToClipPos(i.vertex + offset);
				o.uv = TRANSFORM_TEX(i.texcoord, _MainTex);
				o.uv += float2(0.0, _Time.y * _Speed);

				return o;
			}
			fixed4 frag(v2f i):SV_Target {
				fixed4 c = tex2D(_MainTex, i.uv);
				c.rgb *= _Color.rgb;

				return c;
			}
			ENDCG
		}

	}
}