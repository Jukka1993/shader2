// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/Chapter6/DiffusePixelLevel"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1,1,1,1)
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Diffuse;
            struct a2v
            {
                float4 vertex : POSITION;
				float4 normal:NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
				float3 worldNormal:TEXCOORD0;
            };
            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				//在片元着色器中逐片元获取环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//获取归一化后的法线(来自顶点着色器)
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				// 
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
				fixed3 color = diffuse + ambient;
				return fixed4(color, 1);

            }
            ENDCG
        }
    }
}
