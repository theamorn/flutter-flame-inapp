#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;
uniform float iTime;
uniform float u_day_scale;

out vec4 fragColor;

precision mediump float;

vec2 u_resolution;
float u_time;

const float PI = 3.1415926535897932384626433832795;

float rand(vec2 seed)
{
    return fract(sin(dot(seed.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

float getWaveFromPoint(float xPos, float amplitute, float len,float offsetX){
    return  amplitute * (sin(PI * (offsetX + xPos) / len) + 1.) / 2.;
}

float getWave(float amplitute, float len,float offsetX){
    return getWaveFromPoint(gl_FragCoord.x, amplitute, len, offsetX);
}

float getNoisedWaveFromPoint(float xPos, float amplitute, float len,float offsetX){
    float mainLevel =  getWaveFromPoint(xPos, amplitute, len, offsetX);
    float noiseLevel1 = getWaveFromPoint(xPos,amplitute, len * 2., offsetX + 50.) - 0.5;
    float noiseLevel2 = getWaveFromPoint(xPos, amplitute, len * 3., offsetX + 50.) - 0.5;
    return (mainLevel + noiseLevel1 + noiseLevel2) / 3.;
}

float getNoisedWave(float amplitute, float len,float offsetX){
    return getNoisedWaveFromPoint(gl_FragCoord.x, amplitute, len, offsetX);
}

bool isMountain() {
    float base = 200.0;
    float level1Wave = getWave(200., 200., 0.);
    float level2Wave = getWave(100., 100., 100.);
    float level3Wave = getWave(60., 150., 100.);
    return gl_FragCoord.y <= base + max(max(level1Wave, level2Wave), level3Wave) ;
}

float starScale(){
    float levelGapLen = 50.;
    float starNearestX = floor(gl_FragCoord.x / levelGapLen) * levelGapLen;
    float starNearestY = floor(gl_FragCoord.y / levelGapLen) * levelGapLen;
    
    if(gl_FragCoord.x - starNearestX > levelGapLen / 2.){
        starNearestX += levelGapLen;
    }
    
    if(gl_FragCoord.y - starNearestY > levelGapLen / 2.){
        starNearestY += levelGapLen;
    }
    
    
    if(rand(vec2(starNearestX, starNearestY)) > 0.2){
        return 0.;
    }
    
    if(210. + getNoisedWave(250., 150., 0.) > starNearestY){
        return 0.;
    }
    
    float starRand = rand(vec2(starNearestX, starNearestY));
    float initSize = (sin(u_time * 2. + starRand * 100.) + 2.) / 3. * 80.;
    float size = initSize * starRand;
    float dist = distance(gl_FragCoord.xy, vec2(starNearestX, starNearestY));
    
    // inside star fill
    if(dist < size * 0.4){
        return 1.;
    }
    
    // outside star fill
    if(dist < size){
        return 0.5 * (1. - (dist / size));
    }
    return 0.;
}

vec4 background(vec3 from, vec3 to, float baseOffsetY){
    vec3 color = from;
    vec3 white = to;
    float offsetY = baseOffsetY + getNoisedWave(80., 200., u_time * 100.);
    float len = 1500.;
    
    return vec4(mix(color, white,  1. - min((gl_FragCoord.y + offsetY) / len, 1.)), 1.000);
}

float cometScale(){
    float index = floor(u_time);
    float animateTime = fract(u_time);
    float localRand = rand(vec2(index, index));
    float starSize = (10. + 5. * localRand) * animateTime;
    float orbitSize = 500. + 800. * localRand;
    float spawnX = 100. + 100. * localRand;
    
    float starX = orbitSize * animateTime;
    float starY = sqrt(orbitSize * orbitSize - starX * starX);
    
    float dist = distance(vec2(gl_FragCoord.x,  gl_FragCoord.y), vec2(starX, starY));
    
    if(gl_FragCoord.x < spawnX){
        return 0.;
    }
    
	// inside star fill
    if(dist < starSize * 0.4){
        return 1.;
    }
    
    // outside star fill
    if(dist < starSize){
        return 0.5 * (1. - (dist / orbitSize));
    }
    
    return 0.;
}

float birdScale(vec2 origin, float startPhase, float size){
    float birdSize = size;
    float wingRange = (100. * birdSize / 12.);
    vec2 posFromOrigin = gl_FragCoord.xy - origin;
    float animationProgress = (abs(fract(u_time) - .5) - 0.25) * 4.;
    float xCenter = PI/2. - PI/8.;
    float topRange = sin(startPhase + abs(posFromOrigin.x)/wingRange + xCenter + 2. * PI * fract(u_time) * -1.) * 100. * birdSize / 12.;
    float yCenter = sin(startPhase + xCenter + 2. * PI * fract(u_time) * -1.) * 100. * birdSize / 12.;
    topRange += -1. * yCenter;
    
    if(abs(posFromOrigin.x / wingRange) > PI){
        return 0.;
    }
    
    float range = min(birdSize, birdSize * 2. * (1. - abs(posFromOrigin.x / wingRange) / PI));
    
    if(abs(topRange - posFromOrigin.y) < range){
        return 1.;
    }
    
    return 0.;
}

const float BIRD_NUMBER = 5.;

bool birdFlockScale(bool isUp){
    float duration = 10.;
	bool isBirdFlock = false;
    float runNumber = floor(u_time / duration);
    float animationProgress = 1. - fract(u_time / duration);
    if(isUp){
        animationProgress = fract(u_time / duration);
    }
    
    for(float index = 0.; index < BIRD_NUMBER; index++){
        float localRandom = rand(vec2(index, runNumber));
        float direction = 1.;
        if(localRandom > 0.5){
            direction = -1.;
        }
        vec2 origin = vec2(
            localRandom * u_resolution.x + animationProgress * u_resolution.x / 2. * direction, 
            localRandom * -u_resolution.y + animationProgress * (u_resolution.y + localRandom * u_resolution.y)
        );
        if(birdScale(origin, localRandom * PI * 2., 3. * animationProgress) != 0.){
            return true;
        }
    }
    return isBirdFlock;
}

const float RANDOW_GAP = 20.;
vec4 rainBow(){
    vec2 origin = vec2(u_resolution.x / 2., 0.);
    vec2 posToOrigin = gl_FragCoord.xy - origin;
    float radius = 400. + sin(posToOrigin.x/10. + 2. * PI * fract(u_time));

    if(distance(vec2(0.), posToOrigin) < radius){
        return vec4( 0.);
    }
    
    if(distance(vec2(0.), posToOrigin) < radius + RANDOW_GAP){
        return vec4(0.7421875, 0.375, 0.984375, 1.);
    }
    
    if(distance(vec2(0.), posToOrigin) < radius + RANDOW_GAP * 2.){
        return vec4(0.453125, 0.6640625, 0.984375, 1.);
    }
    
    if(distance(vec2(0.), posToOrigin) < radius + RANDOW_GAP * 3.){
        return vec4(0.48828125, 0.984375, 0.453125, 1.);
    }
    
    if(distance(vec2(0.), posToOrigin) < radius + RANDOW_GAP * 4.){
        return vec4(0.9765625, 0.9296875, 0.2734375, 1.);
    }
    
    if(distance(vec2(0.), posToOrigin) < radius + RANDOW_GAP * 5.){
        return vec4(0.99609375, 0.30859375, 0.21875, 1.);
    }
    
    return vec4(0.);
}

vec4 nightColor(){
	float base = 100.0;
    
	if(gl_FragCoord.y <= 50. + getNoisedWave(60., 100., 100.)){
        return vec4(0.035, 0.113, 0.242, 1.);
    }
    
    if(gl_FragCoord.y <= 80. + getNoisedWave(200., 100., 100.)){
        return vec4(0.136, 0.238, 0.367, 1.);
    }
    
    if(gl_FragCoord.y <= 150. + getNoisedWave(250., 150., 0.)){
        return vec4(0.23, 0.347, 0.496, 1.);
    }
    
    vec3 backgroudTo = vec3(0.085,0.101,0.200);
	vec3 backgroudFrom = vec3(0.712,0.743,0.890);
    vec4 backgroudColor = background(backgroudTo, backgroudFrom, 480.);
    
    if(cometScale() > 0.){
        return mix(backgroudColor, vec4(1), cometScale());
    }
    
    if(starScale() != 0.){
        return mix(backgroudColor, vec4(1), starScale());
    }
    
    return backgroudColor;
}

vec4 dayColor(){
	float base = 100.0;
    
	if(gl_FragCoord.y <= 50. + getNoisedWave(60., 100., 100.)){
        return vec4(0.015625, 0.56640625, 0.1640625, 1.);
    }
    
    if(gl_FragCoord.y <= 80. + getNoisedWave(200., 100., 100.)){
        return vec4(0.0234375, 0.71875, 0.42578125, 1.);
    }
    
    if(gl_FragCoord.y <= 150. + getNoisedWave(250., 150., 0.)){
        return vec4(0, 0.85546875, 0.45703125, 1.);
    }
    
    if(rainBow().w != 0.){
        return rainBow();
    }
    
    vec3 backgroudTo = vec3(0.433, 0.593, 0.816);
	vec3 backgroudFrom = vec3( 1, 1, 1);
    vec4 backgroudColor = background(backgroudTo, backgroudFrom, 180.);
    
    return backgroudColor;
}

vec4 midColor(bool isBirdUp){
	float base = 100.0;
    
	if(gl_FragCoord.y <= 50. + getNoisedWave(60., 100., 100.)){
        return vec4(0.05078125, 0.15234375, 0.15625, 1.);
    }
    
    if(gl_FragCoord.y <= 80. + getNoisedWave(200., 100., 100.)){
        return vec4(0.1171875, 0.2734375, 0.28125, 1.);
    }
    
    if(gl_FragCoord.y <= 150. + getNoisedWave(250., 150., 0.)){
        return vec4(0.2421875, 0.3984375, 0.4296875, 1.);
    }
    
    vec3 backgroudTo = vec3(0.64453125, 0.7421875, 0.78515625);
	vec3 backgroudFrom = vec3(0.9140625, 0.890625, 0.6953125);
    vec4 backgroudColor = background(backgroudTo, backgroudFrom, 180.);
    
        
    if(birdFlockScale(isBirdUp)){
        return vec4(vec3(0.), 1.);
    }
    
    return backgroudColor;
}

float shiftScale(float time){
    if(time == 4.){
        return 24.;
    }
    return mod(time + 20., 24.);
}

float periodRatio(float shiftDayScale, float from, float to){
    float shiftFrom = shiftScale(from);
    float shiftTo = shiftScale(to);
    
    float value = shiftDayScale - shiftFrom;
    float maxValue = shiftTo - shiftFrom;
    return  1. - value / maxValue;
}

void main() {
    // morning				4. - 8.    = 4
    // morning-day gap 		8. - 10.   = 2
    // day 					10. - 14.  = 4
    // day-evening gap 		14. - 16.  = 2
    // evening 				16. - 20.  = 4
    // evening-night gap 	20. - 22.  = 2
    // night 				22. - 2.   = 4
    // night-morning gap 	2. - 4.    = 2

    u_resolution = iResolution;
    u_time = iTime;
    vec2 fragCoord = FlutterFragCoord();
    
    float shiftDayScale = shiftScale(u_day_scale);
    
    if(shiftDayScale <= shiftScale(8.)){
        fragColor = midColor(true);
        return;
    }
    
    if(shiftDayScale <= shiftScale(10.)){
        fragColor = mix(dayColor(), midColor(true), periodRatio(shiftDayScale, 8., 10.));
        return;
    }

    if(shiftDayScale <= shiftScale(14.)){
        fragColor = dayColor();
        return;
    }
    
    if(shiftDayScale <= shiftScale(16.)){
        fragColor = mix(midColor(false), dayColor(), periodRatio(shiftDayScale, 14., 16.));
        return;
    }
    
    if(shiftDayScale <= shiftScale(20.)){
        fragColor = midColor(false);
        return;
    }
    
    if(shiftDayScale <= shiftScale(22.)){
        fragColor = mix(nightColor(), midColor(false), periodRatio(shiftDayScale, 20., 22.));
        return;
    }
    
    if(shiftDayScale <= shiftScale(2.)){
        fragColor = nightColor();
        return;
    }
    
    if(shiftDayScale <= shiftScale(4.)){
        fragColor = mix(midColor(true), nightColor(), periodRatio(shiftDayScale, 2., 4.));
        return;
    }
    
    fragColor =  vec4(vec3(0),1);
}
