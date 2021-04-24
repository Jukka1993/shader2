// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/MyShaderName" {
	Properties {

	}
	SubShader{
		Pass {
			//
			//此处设置渲染状态和标签
			//

			//CGPROGRAM 和 ENDCG 包含着的是CG代码片段
			CGPROGRAM
				//编译指令
				#pragma vertex vert
				#pragma fragment frag

				float4 vert(float4 v:POSITION):SV_POSITION {
					return UnityObjectToClipPos(v);
				}
				fixed4 frag():SV_Target {

					//return fixed4(1.0,0.1,1.0,1.0);
					return fixed4(1,0,1,1);
				}

				//CG代码

			ENDCG
		}
	}
	//SubShader {	//针对显卡B的SubShader(如果前面的针对显卡A的SubShader运行不了,则运行这个)
	//	Pass{
	//		CGPROGRAM

	//		ENDCG
	//	}
	//}
	//SubShader{	//针对显卡C的SubShader(如果前面的针对显卡A和显卡B的SubShader都运行不了，则运行这个)
	//	Pass {
	//		CGPROGRAM

	//		ENDCG
	//	}
	//}
	FallBack "VertexLit"
}