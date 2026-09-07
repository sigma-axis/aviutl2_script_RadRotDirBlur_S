Texture2D src : register(t0);
cbuffer constant0 : register(b0) {
	float2 zmrot_d, zmrot_i, mov_d, mov_i;
	float2 center, size;
	float quality;
};
SamplerState s : register(s0);

float2x2 make_mat(float2 zmrot)
{
	return float2x2(
		zmrot.x, -zmrot.y * size.y / size.x,
		zmrot.y * size.x / size.y, zmrot.x);
}
const static float2x2
	mat_d = make_mat(zmrot_d),
	mat_i = make_mat(zmrot_i);
const static float2 lbd = 0.5 / size, ubd = 1.0 - lbd;

float4 pick_color(float2 pos)
{
	return src.Sample(s, pos);
}
float4 apply(float4 pos : SV_Position) : SV_Target
{
	float2 v = mul(mat_i, pos.xy / size - center + mov_i),
		d = mul(mat_i, mov_d);
	float4 color = 0.0;

	const int n = int(quality);
	for (int i = 0; i < n; i++) {
		color += pick_color(v + center);
		v = mul(mat_d, v + d); d = mul(mat_d, d);
	}

	return color / quality;
}
