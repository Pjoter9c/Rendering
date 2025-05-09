Shader "Unlit/SimpleColor"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white"{}
        _Pallete ("Pallete", 2D) = "white" {}
        _Offset ("Offset", Range(0, 1)) = 0.0
        _SatStep ("SatStep", Range(0, 50)) = 100.0
        _SatAdd ("SatAdd", Range(-1, 1)) = 0.0
        _ValStep ("ValStep", Range(0, 100)) = 100.0
        _ValAdd ("ValAdd", Range(-1, 1)) = 0.0
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            float _Offset;
            float _SatStep;
            float _SatAdd;
            float _ValStep;
            float _ValAdd;
            sampler2D _Pallete;
            float4 _Pallete_ST;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float4 objPos : TEXCOORD2;
                float2 uvPallete : TEXCOORD3;
            };


            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvPallete = TRANSFORM_TEX(v.uv, _Pallete);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.objPos = v.vertex;
                return o;
            }

            float InvLerp(float a, float b, float x)
            {
                return (x - a) / (b - a);
            }

            float3 rgb2hsv(float3 col){
                float minC = min(min(col.r, col.g), col.b);
                float maxC = max(max(col.r, col.g), col.b);
                float delta = maxC - minC;
                float sat = 
                lerp(
                    0,
                    saturate(delta / maxC),
                    maxC != 0
                );

                //sat = delta / maxC;
                float val = maxC;
                //return float3(col.r, col.g, col.g < 0.00001);
                //return float3(sat, sat, sat == 1);

                float hue = 
                    lerp(
                        //0,
                        //lerp(
                            lerp(
                                60 * ((col.g - col.b) / delta % 6), // R
                                60 * ((col.b - col.r) / delta + 2), // G
                                col.g == maxC
                            ),
                            60 * ((col.r - col.g) / delta + 4), // B
                            col.b == maxC
                        //),
                        //delta != 0
                    );
                hue /= 360;

                return float3(hue, sat, val);
            }

            float3 hsv2rgb(float3 col){
                float h = col.x * 360;
                float s = col.y;
                float v = col.z;
                float c = s * v;
                float x = c * (1 - abs((h / 60) % 2 - 1));
                float m = v - c;

                float3 rgb =
                    lerp(
                        // pierwsze 3
                        lerp(
                            // pierwsze
                            rgb = float3(c, x, 0),
                            // drugie i trzecie
                            lerp(
                                rgb = float3(x, c, 0),
                                rgb = float3(0, c, x),
                                step(120, h)
                            ),
                            step(60, h)
                        ),
                        // drugie 3
                        lerp(
                            // czwarte
                            rgb = float3(0, x, c),
                            // piąte i szóste
                            lerp(
                                rgb = float3(x, 0, c),
                                rgb = float3(c, 0, x),
                                step(300, h)
                            ),
                            step(240, h)
                        ),
                        step(180, h)
                    );
                    
                rgb += m;
                return rgb;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float4 col;
                //col = float4(i.objPos);

                /* 
                rgb gradient
                float r, g, b = 0;
          
                r = lerp(
                    lerp(1, 0, i.uv.x * 3),
                    lerp(0, 1, (i.uv.x - 0.66666) * 3),
                    step(0.66666, i.uv.x)
                );

                g = lerp(
                    lerp(0, 1, i.uv.x * 3),
                    lerp(1, 0, (i.uv.x - 0.33333) * 3),
                    step(0.33333, i.uv.x)
                );

                b = lerp(
                    lerp(0, 1, (i.uv.x - 0.33333) * 3),
                    lerp(1, 0, (i.uv.x - 0.66666) * 3),
                    step(0.66666, i.uv.x)
                );

                r = -max(min(-abs(i.uv.x - 0.5) * 6 + 2, 1), 0) + 1;
                g = max(min(-abs(i.uv.x - 1.0/3.0) * 6 + 2, 1), 0);
                b = max(min(-abs(i.uv.x - 2.0/3.0) * 6 + 2, 1), 0);
                
                col = float4(r, g, b, 1);
                */
                col = tex2D(_MainTex, i.uv);
                
                //return col;

                //return col;

                //return col.r > 0;
                
                //col = tex2D(_Pallete, float2(col.r, 0));
                //col = float4(col.xxx, 1);
                
                float3 hsv = rgb2hsv(col);
                //return float4(hsv.xyz, 1);
                //col = col + col * (1 - hsv.z);
                //col = col - (1.0 - col) * (1.0 - hsv.y);
                //return col;

                //return hsv.x;
                col = tex2D(_Pallete, float2(hsv.x, _Offset));
                //return col;
                //return col;
//return tex2D(_Pallete, float2(0, 0));
//return col;
float hue = rgb2hsv(col).x;
//return hue;
hsv.y = saturate(floor(hsv.y * _SatStep) / _SatStep + _SatAdd);
hsv.z = saturate(floor(hsv.z * _ValStep) / _ValStep + _ValAdd);
//return hsv.y;
                //return hsv.y;
                col = float4(hsv2rgb(float3(hue, hsv.y, hsv.z)), 1);
                return col;
                //hsv.y = 0.5;
                //hsv.z = 0.5;

                float3 rgb = hsv2rgb(hsv);
                col = float4(rgb.rgb, 1);
                //return float4(rgb.xyz, 1);
                //return hue;
                
                //return (minC) == 0;
                //return col.r == 0;
                
                //return col;

                //col = col + (1 - col) * (1 - sat);
                //col = col - col * (1 - val);
               //return col;
                //return col.g;

                //return !ceil(col.r) && ceil(col.b);
               
            

                //return float4(0, 0, col.b, 1);


                //float t = (-r + g + b) / 3 + 0.33333;
                //hue = lerp(0, 1, t);
                
                //return hue;
             
                

                //col = col + (1 - col) * (1 - sat);
                //col = col - col * (1 - val);

                
                //float4 x = clamp(col, 0, 1);
                return col;
            }


            ENDCG
        }
    }
}
