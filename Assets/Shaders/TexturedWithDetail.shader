// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/TexturedWithDetail"{

	Properties{
		_Tint ("Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
		_DetailTex ("DetailTeture", 2D) = "gray" {}
	}
	
	SubShader{

		Pass{
			CGPROGRAM

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			#include "UnityCG.cginc"

			float4 _Tint;
			sampler2D _MainTex, _DetailTex;
			float4 _MainTex_ST; // tiling(XY), offset(ZW) textury _MainTex
			float4 _DetailTex_ST;

			struct Interpolators{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uvDetail : TEXCOORD1;
			};

			struct VertexData{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
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
				i.uv = TRANSFORM_TEX(v.uv, _MainTex);
				i.uvDetail = TRANSFORM_TEX(v.uv, _DetailTex);
				return i;
			}

			float4 MyFragmentProgram(Interpolators i) : SV_TARGET{
				float4 color = tex2D(_MainTex, i.uv) * _Tint;
				color *= tex2D(_DetailTex, i.uvDetail) * unity_ColorSpaceDouble;
				return color;
				
			}

			ENDCG
		}
	}
}