Shader "Unlit/rollBackground" {
	Properties{
		//_Color("color", Color) = (1,1,1,1)
		_Tex1("tex1", 2D) = "white"{}
		_Tex2("tex2", 2D) = "white"{}
		_Scroll1("scroll speed 1", Range(0, 10)) = 1
		_Scroll2("scroll speed 2", Range(0, 10)) = 1
		_Multipler("layer multiplier", Float) = 1
	}
	SubShader {
		Pass{

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCg.cginc"
		sampler2D _Tex1;
		float4 _Tex1_ST;
		sampler2D _Tex2;
		float4 _Tex2_ST;
		float _Scroll1;
		float _Scroll2;
		float _Multipler;
		struct v2f {
			float4 pos:SV_POSITION;
			float4 uv:TEXCOORD0;
		};
		v2f vert(appdata_base i) {
			v2f o;
			o.pos = UnityObjectToClipPos(i.vertex);
			float2 uv = TRANSFORM_TEX(i.texcoord, _Tex1);
			o.uv.xy = uv + float2(_Scroll1 * _Time.y, 0);
			o.uv.zw = uv + float2(_Scroll2 * _Time.y, 0);
			return o;
		}
		fixed4 frag(v2f i):SV_Target {
			fixed4 col1 = tex2D(_Tex1, i.uv.xy);
			fixed4 col2 = tex2D(_Tex2, i.uv.zw);
			fixed4 col = lerp(col1,col2,col2.a);
			//col1 + col2;
			return col;
		}

		ENDCG
		}
	}
}
