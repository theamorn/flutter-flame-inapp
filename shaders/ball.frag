#include <flutter/runtime_effect.glsl>
uniform vec2 uSize;
uniform float iTime;
vec2 iResolution;

out vec4 fragColor;

#define PI 3.14159265359
#define FLT_MAX 3.402823466e+38

// https://www.shadertoy.com/view/4dS3Wd
float hash(float p) { p = fract(p * 0.011); p *= p + 7.5; p *= p + p; return fract(p); }


mat2 rot(float a) {
    float ca =cos(a);
    float sa=sin(a);
    return mat2(ca,sa,-sa,ca);
}

//------------------

float sminCubic( float a, float b, float k )
{
    float h = max( k-abs(a-b), 0.0 )/k;
    return min( a, b ) - h*h*h*k*(1.0/6.0);
}

float opExtrussion( in vec3 p, in float sdf, in float h )
{
    vec2 w = vec2( sdf, abs(p.z) - h );
  	return min(max(w.x,w.y),0.0) + length(max(w,0.0));
}

// https://www.shadertoy.com/view/wlyBWm
vec2 smoothrepeat_asin_sin(vec2 p,float smooth_size,float size){
    p/=size;
    p=asin(sin(p)*(1.0-smooth_size));
    return p*size;
}

//--------------

// don't remember were i took this from but I think I started from here 
// https://www.researchgate.net/publication/300124211_Interactive_Procedural_Building_Generation_Using_Kaleidoscopic_Iterated_Function_Systems
vec2 dKifs(vec2 p, vec2 c, float s, float t1, float t2) {
    float r2 = p.x*p.x+p.y*p.y;
    float i;
    for (i=0.;i<6. && r2 < 1000.; i++) {
        p *= rot(t1);
        
        p = abs(p);
        if (p.x - p.y < 0.) {
            float x1=p.y;
            p.y = p.x;
            p.x = x1;
        }
        
        p *= rot(t2);
        
        p.x = s*p.x-c.x*(s-1.);
        p.y=s*p.y;
        if(p.y>0.5*c.y*(s-1.)) p.y-=c.y*(s-1.);
      
        p.y += .1 *s;
        p.y*=p.y*.45;
        p.x -= .2 *s;
        
        r2 = p.x*p.x+p.y*p.y;
    }
    
    return vec2( (sqrt(r2)-2.)*pow(s,-i), i);
}

vec3 camPos;
vec2 map( in vec3 p ) {
    float d = FLT_MAX;
    float mat = -1.;
    
    vec2 f;
    // extruded fractal
    {
    vec3 q = p;
    q.xy = smoothrepeat_asin_sin(p.xy,.04, 4.0);
    float c = 15.;
    float zId = ceil((q.z+.5*c) / c);
    q.z = mod(q.z+.5*c, c)-.5*c;

    float r1 = 0.2 + hash(zId*1234.)*.75 + smoothstep(0., .2, sin((camPos.z+1.5)*PI / 15.)) *.15 ;
    float r2 = mix(0.2, 0.5, hash(zId*4312.));
    f = dKifs( q.xy*.2, vec2(1.), 3., r1, r2);
    
    if ( f.x < d ) mat = 0.;
    d = min(d,opExtrussion( q, f.x, .5) ) - 0.002;
    }

    
    // plane
    {
    vec3 q = p;
    float c = 15.;
    q.z = mod(q.z+.5*c, c)-.5*c;
    
    q.xy *= .5;
    float s = 1.0;
	float t = 0.0;
	for( int i=0; i<2; i++ )
	{
        t += s*.5*(cos(6.2831*q.x+iTime*5.) + cos(6.2831*q.y+iTime*2.));;
		s *= 0.5 + 0.1*t;
        q.xy = 0.97*mat2(1.6,-1.2,1.2,1.6)*q.xy + (t-0.5)*0.2;
	}
    
    float dP = abs(q.z  - 0.01 - (cos(q.x*4.+iTime)*.5+.5)*.02 );
    if (dP-.3 < d) mat = 1.;
    d = sminCubic( d,  dP, .6 );
    }
    
    return vec2(d, mat);
}

// https://iquilezles.org/articles/normalsSDF
vec3 calcNormal( in vec3 pos )
{
    vec2 e = vec2(1.0,-1.0)*0.5773;
    const float eps = 0.0005;
    return normalize( e.xyy*map( pos + e.xyy*eps ).x + 
					  e.yyx*map( pos + e.yyx*eps ).x + 
					  e.yxy*map( pos + e.yxy*eps ).x + 
					  e.xxx*map( pos + e.xxx*eps ).x );
}
 
// https://www.shadertoy.com/view/MdS3Rw
float ao( vec3 v, vec3 n ) {
	float sum = 0.0;
	float att = 3.0;
    float aoStep = .1;
    float aoScale = .3;
	float len = aoStep;
	for ( int i = 0; i < 4; i++ ) {
		sum += ( len - map( v + n * len ).x ) * att;
		
		len += aoStep;
		
		att *= 0.5;
	}
	
	return max( 1.0 - sum * aoScale, 0.0 );
}

// https://www.shadertoy.com/view/flGyDd
// License: Unknown, author: nmz (twitter: @stormoid), found: https://www.shadertoy.com/view/NdfyRM
vec3 sRGB(vec3 t) {
  return mix(1.055*pow(t, vec3(1./2.4)) - 0.055, 12.92*t, step(t, vec3(0.0031308)));
}

vec3 aces_approx(vec3 v)
{
    v = max(v, 0.0);
    v *= 0.6f;
    float a = 2.51f;
    a = 2.;
    float b = 0.03f;
    float c = 2.43f;
    c = 1.;
    float d = 0.59f;
    float e = 0.14f;
    return clamp((v*(a*v+b))/(v*(c*v+d)+e), 0.0f, 1.0f);
}

vec3 postProcess(vec3 col) {
    col -= .1;
    col += col*col*.4;
    col = aces_approx(col);
    col = sRGB(col);
    return col;
}

vec2 march(vec3 ro, vec3 rd, float tmax, inout float t, int iMax, float e, float hStep) {
    vec2 h;
    for( int i=0; i<iMax; i++ )
    {
        vec3 pos = ro + t*rd;
        h = map(pos);
        if( h.x<e || t>tmax ) break;
        t += h.x*hStep;
    }
    return h;
}

vec3 shade(vec3 pos, vec3 nor, vec3 ro, vec3 rd, float t) {
    vec3 col = vec3(0.15,0.25,0.4);
    float m = mod(pos.z, 15.);
    col *= pow(1.-mod(pos.z, 15.)/15., 80.)*6.5;
    
    float fractal = 1.-step(m, .1);
    vec3 lDir = vec3(0.57703);
    lDir = normalize(vec3(0.3, .6, .6));
    float dif = clamp( dot(nor, lDir), 0.0, 1.0 );
    vec3  ref   = reflect(rd, nor);
    float spec  = max(dot(ref, lDir), 0.0);
    col += (spec*.5 + dif * vec3(.1, .15, .25)*.5) * fractal *.8;
    
    float plane = step(m, .3);
    col = clamp(col + -.2 * plane, 0., 1.);
    col += plane * col * col * .7;
    
    return col;
}

#define AA 2

void main()
{
    iResolution = uSize;
    vec2 fragCoord = FlutterFragCoord();
    vec3 ro = vec3(0., 0., 15. - iTime*2.5);
    camPos = ro;
    vec3 ta = vec3( 0.0, 0., 0.0 - iTime*2.5 );
    // camera matrix
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    vec3 vv =          ( cross(uu,ww));
    
    // render
    vec3 tot = vec3(0.0);
    
    #if AA>1
    for( int m=0; m<AA; m++ )
    for( int n=0; n<AA; n++ )
    {
        // pixel coordinates
        vec2 o = vec2(float(m),float(n)) / float(AA) - 0.5;
        vec2 p = (-iResolution.xy + 2.0*(fragCoord+o))/iResolution.y;
        #else    
        vec2 p = (-iResolution.xy + 2.0*fragCoord)/iResolution.y;
        #endif


	    // create view ray
        vec3 rd = normalize( p.x*uu + p.y*vv + 1.5*ww );

        rd.xy *= rot(sin(iTime*PI/7.5)*.4);
        rd.xz *= rot(sin(iTime*PI/7.5 * 2.)*.15);
        
        // raymarch
        float tmax = 40.0;
        float t = 0.0;
        vec2 h = march(ro, rd, tmax, t, 40, 0.005, .8);
    
        // shading/lighting	
        vec3 col = vec3(0.);
        if( t<tmax )
        {
            vec3 pos = ro + t*rd;
            vec3 nor = calcNormal(pos);
            col = shade(pos, nor, ro, rd, t);

            float ao = clamp(pow(ao(pos,nor),5.)*3., 0., 1.);
            col = vec3(ao) * col;
            // thin layer transparent material or something 
            if ( h.y == 1.) {
               vec3 ro2 = pos - nor * .5;
               // interpolation suggest by alro ty :)
               float ior = mix(1.2, 1., smoothstep(0.9, 1., cos(ro.z*PI / 7.5 - .3) ) );
               vec3 rd2 = refract(rd, nor, ior);
               // raymarch again
               tmax = 60.;
               t = 0.;
               vec2 h2 = march(ro2, rd2, tmax, t, 50, 0.01, 1.);
               // shade again
               vec3 col2 = vec3(0.);
               if (t<tmax) {
                   vec3 pos2 = ro2 + t*rd2;
                   vec3 nor2 = calcNormal(pos2);
                   col2 = shade(pos2, nor2, ro2, rd2, t);
               }
               col = mix(col, col2, .5);
            }
        }
        
        col = postProcess(col); // doing it here reduces some artifacts
	    tot += col;
    #if AA>1
    }
    tot /= float(AA*AA);
    #endif
    
    //tot = postProcess(tot);

	fragColor = vec4( tot, 1.0 );
}