// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/FirstShader"{

	Properties{
		_Tint ("Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
	}
	
	SubShader{

		Pass{
			CGPROGRAM

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			#include "UnityCG.cginc"

			float4 _Tint;
			sampler2D _MainTex;
			float4 _MainTex_ST; // tiling(XY), offset(ZW) textury _MainTex

			struct Interpolators{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			struct VertexData{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
			};

			// : POSITION - semantyka, jak interpretowana jest dana zmienna, gdzie jest zapisywana w karcie graficznej
			// POSITION - pozycja wierzcho�ka lokalnie, na wej�cie do vertex shadera
			// SV_POSITION - pozycja wierzcho�ka na ekranie, na wyj�cie vertex shadera i wej�cie fragment shadera
			// TEXCOORD0, TEXCOORD1, ..., TEXCOORD7 (lub 15) - przechowuje max float4
			//		- wszystko co jest interpolowane i nie jest pozycj� vertex�w
			// SV_TARGET - finalny kolor piksela
			// nazwy zmiennych nie musz� si� zgadza�, wa�ne aby semantyka si� zgadza�a
			// utworzenie innej zmiennej w tej samej semantyce nadpisze poprzedni�

			Interpolators MyVertexProgram(VertexData v){
				Interpolators i;
				i.position = UnityObjectToClipPos(v.position);
				i.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return i;
			}

			float4 MyFragmentProgram(Interpolators i) : SV_TARGET{
				return tex2D(_MainTex, i.uv) * _Tint;
			}

			ENDCG
		}
	}
}