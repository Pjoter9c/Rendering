// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/TextureSplatting"{

	Properties{
		_MainTex ("Texture", 2D) = "white" {}
		[NoScaleOffset] _Texture1 ("Texture1", 2D) = "white" {}
		[NoScaleOffset] _Texture2 ("Texture2", 2D) = "white" {}
		[NoScaleOffset] _Texture3 ("Texture3", 2D) = "white" {}
		[NoScaleOffset] _Texture4 ("Texture4", 2D) = "white" {}
	}
	
	SubShader{

		Pass{
			CGPROGRAM

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST; // tiling(XY), offset(ZW) textury _MainTex

			sampler2D _Texture1, _Texture2, _Texture3, _Texture4;

			struct Interpolators{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uvSplat : TEXCOORD1;
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
				i.uvSplat = v.uv;
				return i;
			}

			float4 MyFragmentProgram(Interpolators i) : SV_TARGET{
				float4 splat = tex2D(_MainTex, i.uvSplat);
				return
					tex2D(_Texture1, i.uv) * splat.r +
					tex2D(_Texture2, i.uv) * splat.g + 
					tex2D(_Texture3, i.uv) * splat.b +
					tex2D(_Texture4, i.uv) * (1 - splat.r - splat.g - splat.b);
			}

			ENDCG
		}
	}
}