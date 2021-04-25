// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/AlphaBlendMatBothSide"
{
    Properties
    {
		_Color ("Main Tint",Color) = (1.0,1.0,1.0,1.0)
        _MainTex ("Texture", 2D) = "white" {}
		_AlphaScale ("Alpha Scale", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True"}
        LOD 100

        Pass
        {
			Tags {"LightMode"="ForwardBase"}
			ZWrite Off
			Cull Front
			Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
			#include "Lighting.cginc"
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                //float2 uv : TEXCOORD0;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
				float4 vertex:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				float2 uv:TEXCOORD2;
            };

			float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _AlphaScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed4 texColor = tex2D(_MainTex, i.uv);
				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = albedo * UNITY_LIGHTMODEL_AMBIENT;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

				return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
            }
            ENDCG
        }
		Pass
        {
			Tags {"LightMode"="ForwardBase"}
			ZWrite Off
			Cull Back
			Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
			#include "Lighting.cginc"
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                //float2 uv : TEXCOORD0;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
				float4 vertex:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				float2 uv:TEXCOORD2;
            };

			float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _AlphaScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed4 texColor = tex2D(_MainTex, i.uv);
				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = albedo * UNITY_LIGHTMODEL_AMBIENT;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

				return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
            }
            ENDCG
        }
    }
}
