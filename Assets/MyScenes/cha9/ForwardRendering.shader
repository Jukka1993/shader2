// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/ForwardRendering"
{
    Properties
    {
        _Diffuse("diffuse", Color) = (1.0, 1.0, 1.0,1.0)
		_Specular("specular",Color) = (1.0, 1.0, 1.0, 1.0)
		_Gloss("gloss",Range(8, 256)) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
			Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM

			#pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
			#include "Lighting.cginc"

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
				
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
            };

            float _Gloss;
			float4 _Diffuse;
			float4 _Specular;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0).xyz;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//discard;

				fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * max(0,dot(worldLightDir, worldNormal));

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 halfDir = normalize(viewDir + worldLightDir);
				fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(max(0,dot(halfDir, worldNormal)),_Gloss);
				fixed3 atten = 1.0;
				return fixed4(ambient + (diffuse + specular) * atten, 1.0);
            }
            ENDCG
        }
		Pass{
			Tags{"LightMode" = "ForwardAdd"}
			Blend One One
			CGPROGRAM
			#pragma multi_compile_fwdadd
			#pragma vertex vert
            #pragma fragment frag
			#include "Lighting.cginc"

            #include "UnityCG.cginc"
			#include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
				
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
            };

            float _Gloss;
			float4 _Diffuse;
			float4 _Specular;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0).xyz;
				#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
				#endif

				fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * max(0,dot(worldLightDir, worldNormal));

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 halfDir = normalize(viewDir + worldLightDir);
				fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(max(0,dot(halfDir, worldNormal)),_Gloss);
				//#ifdef USING_DIRECTIONAL_LIGHT
				//	fixed3 atten = 1.0;
				//#else
				//	float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
				//	fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				//#endif
                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed atten = 1.0;
                #else
                    #if defined (POINT)
                        // 把点坐标转换到点光源的坐标空间中，_LightMatrix0由引擎代码计算后传递到shader中，这里包含了对点光源范围的计算，具体可参考Unity引擎源码。经过_LightMatrix0变换后，在点光源中心处lightCoord为(0, 0, 0)，在点光源的范围边缘处lightCoord模为1
                        float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
                        // 使用点到光源中心距离的平方dot(lightCoord, lightCoord)构成二维采样坐标，对衰减纹理_LightTexture0采样。_LightTexture0纹理具体长什么样可以看后面的内容
                        // UNITY_ATTEN_CHANNEL是衰减值所在的纹理通道，可以在内置的HLSLSupport.cginc文件中查看。一般PC和主机平台的话UNITY_ATTEN_CHANNEL是r通道，移动平台的话是a通道
                        fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                    #elif defined (SPOT)
                        // 把点坐标转换到聚光灯的坐标空间中，_LightMatrix0由引擎代码计算后传递到shader中，这里面包含了对聚光灯的范围、角度的计算，具体可参考Unity引擎源码。经过_LightMatrix0变换后，在聚光灯光源中心处或聚光灯范围外的lightCoord为(0, 0, 0)，在点光源的范围边缘处lightCoord模为1
                        float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
                        // 与点光源不同，由于聚光灯有更多的角度等要求，因此为了得到衰减值，除了需要对衰减纹理采样外，还需要对聚光灯的范围、张角和方向进行判断
                        // 此时衰减纹理存储到了_LightTextureB0中，这张纹理和点光源中的_LightTexture0是等价的
                        // 聚光灯的_LightTexture0存储的不再是基于距离的衰减纹理，而是一张基于张角范围的衰减纹理
                        fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                    #else
                        fixed atten = 1.0;
                    #endif
                #endif
				return fixed4((diffuse + specular) * atten, 1.0);
            }


			ENDCG
		}
    }
}
