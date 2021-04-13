// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'	//这个注释是ShaderlabVS插件替换了我写的代码后自动添加的日志

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unit/Test" {	//这是一个Shader 在Unity的Shader的路径应该是 Unit/Test
	
	Properties {

	}
	SubShader{			//这是一个子着色器,如果运行设备的显卡支持这个子着色器,那么就运行这个子着色器
		

		Pass {	//如果编写的是顶点-片元着色器，每个子着色器可以包含一个或者多个Pass，如果Pass所在的子着色器能够在当前CPU上运行,那么该着色器里所有的Pass都会一次执行，每个Pass的输出结果都会以指定的方式与上一步的结果进行混合，最终输出
			Name MYFIRSTPASS	//这里定义了PASS的名字，其他地方可以通过 UsePass "Test/MYFIRSTPASS" 来复用这个Pass，unity内部会把所有Pass的名字转换为大写字母表示,因此使用UsePass命令时必须使用大写字母



			CGPROGRAM	//CGPROGRAM 开头到 ENDCG 结尾这中间的部分是CG代码片段
				#pragma vertex vert	//编译指令 告诉Unity 下面的函数 vert 包含了顶点着色器的代码，这里的vert可以换成vert1,vert2都可以，只要下面有对应名字的函数用来实现顶点着色器的功能
				#pragma fragment frag	//编译指令 告诉Unity 下面的函数 frag 包含了片元着色器的代码，这里的frag可以换成frag1，frag2都可以，只要下面有对应名字的函数用来实现片元着色器的功能


				//vert 为函数名
				//由于上面的 #pragma vertex vert 因此这个函数是作为定点着色器的函数,从而 逐顶点运行的
				//第一个float4 为返回类型 
				//第二个float4 为参数v的类型
				//输入参数 v 包含了当前处理的顶点的位置,这是由 POSITION 语义来指定的
				//第一个float4指定了返回类型，函数的返回值是该顶点在剪裁空间中的位置，这是由SV_POSITION语义来指定的
				//POSITION 和 SV_POSITION 都是CG/HLSL中的语义(semantics)他们是不可省略的,这些语义告诉系统用户需要输入哪些值,以及用户的输出是什么。
				//例如这里，POSITION 将告诉Unity，把模型的顶点坐标填充到输入参数 v 中，SV_POSITION 将告诉Unity，该顶点着色器的输出是剪裁空间中的顶点坐标。
				//如果没有这些语义来限定输入输出参数的话，渲染器就完全不知道用户的输入输出参数是什么，因此会得到错误的结果。
				float4 vert(float4 v:POSITION) :SV_POSITION {
					//return mul(UNITY_MATRIX_MVP, v);	//将 物体空间的顶点坐标通过 当前模型 * 视图 * 投影矩阵 转换到剪裁空间
					return UnityObjectToClipPos(v);		// Unity提供了内置的函数，由于安装了 ShaderlabVS 插件，插件自动将上面的这个语句替换为了这个函数，可以看到本Shader顶部的NOTE
				}
				//frag 为函数名
				//由于上面的 #pragma fragment frag 因此这个函数是作为片元着色器的函数，从而逐片元运行的
				//在本例子中frag没有任何输入，其输出是一个float4 的变量 ，由于使用了 SV_Target语义进行了限定
				//相当于告诉了渲染器，把这个输出的颜色存储到一个渲染目标中，这里将输出到默认的帧缓存中。
				float4 frag():SV_Target {
					return fixed4(0.0,0.0,1.0,1.0);
				}
			ENDCG
		}
		Pass {
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				float4 vert(float4 v:POSITION):SV_POSITION {
					return UnityObjectToClipPos(v);
				}
				float4 frag():SV_Target{
					return fixed4(1.0,0.0,0.0,1.0);
				}
			ENDCG
		}
	}
	SubShader{	//这是另一个子着色器,如果上面的子着色器不能运行则会来运行这个子着色器
		Pass {
			CGPROGRAM
				//定义一个结构体,来定义顶点着色器的输入
				//名字是随意的（不是关键字就行了），里面可以包含一些数据用于顶点着色器的输入
				//这里命名为 a2v 的意思是表示这个结构体是 应用 -> 顶点着色器 这个过程用的, 即 Application To Vertex Shader
				struct a2v {
					//POSITION 语义告诉Unity，用模型空间的顶点坐标填充 vertex 这个变量的值
					float4 vertex:POSITION;
					//NORMAL 语义告诉Unity， 用模型空间的法线方向填充 normal 这个变量的值
					float3 normal:NORMAL;
					//TEXCOORD0 语义告诉Unity， 用模型的第一套纹理坐标填充texcoord变量
					float4 texcoord:TEXCOORD0;
				}

				/**
					定义结构体的格式为
					
					struct StructName {
						Type Name: Semantic; //类型1 名字1: 语义1;
						Type Name: Semantic; //类型2 名字2: 语义2;
						...
					}
				**/


				#program vertex vert
				#program fragment frag
				//这里的vert函数的输入 v 的类型是上面定义的 a2v 结构体,不需要再指定语义了,因为a2v的定义里的字段已经给出语义了
				float4 vert(a2v v) :SV_POSITION {
					return UnityObjectToClipPos(v);
				}
				float4 frag():SV_Target {
					return fixed4(1.0,1.0,1.0,1.0);
				}
			ENDCG
		}
	}
	SubShader{	//这又是另一个子着色器,如果前面的子着色器不能运行则会来运行这个子着色器
		Pass {
			CGPROGRAM
				#program vertex vert
				#program fragment frag

				struct a2v {
					float4 vertex: POSITION;
					float3 normal: NORMAL;
					float4 texcoord: TEXCOORD0;
				}
				//使用一个结构体,用来定义顶点着色器的输出(同时用作片元着色器的输入, 因此命名为 v2f ,即 VertexShader To Fragment Shader)
				struct v2f {
					//SV_POSITION 语义告诉Unity，pos里包含了顶点在裁剪空间中的位置信息
					float4 pos: SV_POSITION;
					// COLOR0语义可以用于存储颜色信息
					fixed3 color:COLOR0;
				}

				float4 vert(float4 v:POSITION) :SV_POSITION {
					v2f o;
					o.pos = UnityObjectToClipPos(v);
					o.color = v.normal * 0.5 + fixed3(0.5,0.5,0.5);
					return o;
				}
				float4 frag(v2f i):SV_Target {
					//将插值后的i.color 显示到屏幕上，注意这里的插值的过程不是指下一句的return语句里插值，而是顶点着色器是逐顶点运行的，
					//片元着色器是逐片元运行的，任意两个顶点之间，肯定有无数个片元（实际上显示的时候根据放大程度，只需要一定数量的像素的数目了吧），
					//因此这个frag函数执行的时候的输入 i，就已经是顶点着色器的输出的插值的结果了
					return fixed4(i.color, 1.0);	//而这里的fixed4（i.color, 1.0); 仅仅是说i.color 是fixed3 类型的变量，用fixed4函数将其后面补一个1，变为发ixed变量而已，返回之后，该片元着色器作用的像素就显示这个颜色了
				}
			ENDCG
		}
	}
	Fallback "VertexLit"	//这个是保底措施,如果上面所有的子着色器都不能在当前设备运行,则运行这个着色器，是Unity内置的
	//Fallback Off			//上面的保底措施也可以是 Fallback Off ,就是说不要保底的意思
}