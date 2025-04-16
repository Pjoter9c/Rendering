// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/FirstLightShader"{

	Properties{
		_Tint ("Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Albedo", 2D) = "white" {}
		[Gamma] _Metallic("Metallic", Range(0, 1)) = 0
		_Smoothness ("Smoothness", Range(0, 1)) = 0.5
	}
	
	SubShader{

		Pass{
			Tags{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma target 3.0

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			//#include "UnityCG.cginc" // a lot of math functions
			//#include "UnityStandardBRDF.cginc" // even more math functions
			//#include "UnityStandardUtils.cginc" // light functions
			#include "UnityPBSLighting.cginc" // PBS shading

			float4 _Tint;
			sampler2D _MainTex;
			float4 _MainTex_ST; // tiling(XY), offset(ZW) textury _MainTex
			float _Metallic;
			float _Smoothness;

			struct VertexData{
				float4 position : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};
			
			struct Interpolators{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};


			// : POSITION - semantyka, jak interpretowana jest dana zmienna, gdzie jest zapisywana w karcie graficznej
			// POSITION - pozycja wierzcho³ka lokalnie, na wejœcie do vertex shadera
			// SV_POSITION - pozycja wierzcho³ka na ekranie, na wyjœcie vertex shadera i wejœcie fragment shadera
			// TEXCOORD0, TEXCOORD1, ..., TEXCOORD7 (lub 15) - przechowuje max float4
			//		- wszystko co jest interpolowane i nie jest pozycj¹ vertexów
			// SV_TARGET - finalny kolor piksela
			// nazwy zmiennych nie musz¹ siê zgadzaæ, wa¿ne aby semantyka siê zgadza³a
			// utworzenie innej zmiennej w tej samej semantyce nadpisze poprzedni¹

			Interpolators MyVertexProgram(VertexData v){
				Interpolators i;
				i.position = UnityObjectToClipPos(v.position);
				i.worldPos = mul(unity_ObjectToWorld, v.position);
				i.uv = TRANSFORM_TEX(v.uv, _MainTex);
				i.normal = UnityObjectToWorldNormal(v.normal);
				return i;
			}

			float4 MyFragmentProgram(Interpolators i) : SV_TARGET{
				i.normal = normalize(i.normal);
				float3 lightDir = _WorldSpaceLightPos0.xyz;
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				
				float3 lightColor = _LightColor0.rgb;
				float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint;

				float3 specularTint;
				float oneMinusReflectivity;
				albedo = DiffuseAndSpecularFromMetallic(
					albedo, _Metallic, specularTint, oneMinusReflectivity
				);
				
				UnityLight light;
				light.color = lightColor;
				light.dir = lightDir;
				light.ndotl = DotClamped(i.normal, lightDir);

				UnityIndirect indirectLight;
				indirectLight.diffuse = 0;
				indirectLight.specular = 0;

				return UNITY_BRDF_PBS(
					albedo, specularTint,
					oneMinusReflectivity, _Smoothness,
					i.normal, viewDir,
					light, indirectLight);
			}
			
			ENDCG
		}
	}
}