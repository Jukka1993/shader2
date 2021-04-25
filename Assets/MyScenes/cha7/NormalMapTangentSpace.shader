Shader "Unlit/NormalMapTangentSpace11"
{
    Properties
    {
		_Color ("Color Tint", Color) = (1.0, 1.0, 1.0,1.0)
        _MainTex ("Texture", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1.0
		_Specular("Specular", Color) = (1.0, 1.0, 1.0,1.0)
		_Gloss ("gloss", Range(8, 256)) = 20
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
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
			#include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
            };

			float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			float4 _Specular;
			float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				//TANGENT_SPACE_ROTATION;
				float3 binormal = cross( normalize(v.normal), normalize(v.tangent.xyz) ) * v.tangent.w;
				float3x3 rotation = float3x3( v.tangent.xyz, binormal, v.normal );
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				//从法线贴图里获取法线（原始的）
				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);

				//定义最终的法线(切线空间下的)
				fixed3 tangentNormal;

				//解包原始的法线
				tangentNormal = UnpackNormal(packedNormal);
				//使用_BumpScale控制凹凸程度
				tangentNormal.xy *= _BumpScale;
				//重设z来归一化法线
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));
				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);	//Blinn-Phong
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)),_Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
}
