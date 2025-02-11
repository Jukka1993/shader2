﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/specular_per_pixel"
{
    Properties
    {
        _Diffuse("diffuse color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Specular("specular color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Gloss("gloss", Range(8,256)) = 20
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
            // make fog work
            //#pragma multi_compile_fog

            #include "UnityCG.cginc"
			#include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                //float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
            };

            //sampler2D _MainTex;
            //float4 _MainTex_ST;
			float4 _Diffuse;
			float4 _Specular;
			float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * max(0, dot(worldNormal, worldLightDir));
				fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(reflectDir,worldViewDir)),_Gloss);
				fixed4 col = fixed4(ambient + diffuse + specular, 1.0);

                //// sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);
                //// apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
