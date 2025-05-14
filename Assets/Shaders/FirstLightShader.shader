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

			#include "MyLighting.cginc"

			ENDCG
		}

		Pass{
			Tags{
				"LightMode" = "ForwardAdd"
			}
			Blend One One
			ZWrite Off

			CGPROGRAM

			#pragma target 3.0

			#pragma multi_compile DIRECTIONAL POINT

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			//#include "UnityCG.cginc" // a lot of math functions
			//#include "UnityStandardBRDF.cginc" // even more math functions
			//#include "UnityStandardUtils.cginc" // light functions

			#include "MyLighting.cginc"

			ENDCG
		}
	}
}