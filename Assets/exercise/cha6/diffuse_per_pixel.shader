Shader "Unlit/diffuse_per_pixel"
{
    Properties
    {
        _Diffuse("Diffuse Color", Color) = (1.0, 1.0, 1.0, 1.0)
		//_Gloss("Gloss", Range(8, 256)) = 20
		//_Specular("specular", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
			#include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float3 worldNormal: TEXCOORD0;
				float3 worldPos:TEXCOORD1;
            };

            float4 _Diffuse;
			float4 _Specular;
			float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(UNITY_MATRIX_M,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				//fixed3 reflectDir = reflect(-worldLightDir, worldNormal);//Phong model
				//fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos)))

				fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * max(0, dot(worldNormal, worldLightDir));

				//fixed3 specular = _Specular.rgb * LightColor0.rgb * pow(saturate(0,dot(worldViewDir, reflectDir)),_Gloss);
				return fixed4(ambient + diffuse,1.0);
            }
            ENDCG
        }
    }
}
