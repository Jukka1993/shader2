// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/Chapter6/DiffuseVertexLevel"
{
    Properties
    {
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
			Tags{ "LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            //#pragma multi_compile_fog
			#include "Lighting.cginc"
            #include "UnityCG.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
				float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
				fixed3 color : COLOR;
            };

			fixed4 _Diffuse;

            v2f vert (a2v v)
            {
                v2f o;
				//将顶点转换到剪裁空间,等价于
				//o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);

				//获取环境光(的强度和颜色)
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//将法线从物体空间转换为世界坐标
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				//获取世界空间中的光的方向
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				//计算漫反射部分
				fixed3  diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));

				o.color = ambient + diffuse;

				
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				return fixed4(i.color, 1.0);
            }
            ENDCG
        }
    }
	Fallback "VertexLit"
}
