Texture2D src : register(t0);
cbuffer constant0 : register(b0) {
	float2 zmrot_d_r, zmrot_d_g, zmrot_d_b;
	float2 zmrot_i_r, zmrot_i_g, zmrot_i_b;
	float2 mov_d_r, mov_d_g, mov_d_b;
	float2 mov_i_r, mov_i_g, mov_i_b;
	float2 center, size;
	float quality, mode_blend;
};
SamplerState s : register(s0);

float2x2 make_mat(float2 zmrot)
{
	return float2x2(
		zmrot.x, -zmrot.y * size.y / size.x,
		zmrot.y * size.x / size.y, zmrot.x);
}
const static float2x2
	mat_d[3] = { make_mat(zmrot_d_r), make_mat(zmrot_d_g), make_mat(zmrot_d_b) },
	mat_i[3] = { make_mat(zmrot_i_r), make_mat(zmrot_i_g), make_mat(zmrot_i_b) };
const static float2 lbd = 0.5 / size, ubd = 1.0 - lbd;

float4 pick_color(float2 pos)
{
	return src.Sample(s, pos);
}
float4 apply_chroma(float4 pos : SV_Position) : SV_Target
{
	float2 v[3] = {
		mul(mat_i[0], pos.xy / size - center + mov_i_r),
		mul(mat_i[1], pos.xy / size - center + mov_i_g),
		mul(mat_i[2], pos.xy / size - center + mov_i_b)
	}, d[3] = {
		mul(mat_i[0], mov_d_r),
		mul(mat_i[1], mov_d_g),
		mul(mat_i[2], mov_d_b)
	};
	float2 color[3] = { { 0.0, 0.0 }, { 0.0, 0.0 }, { 0.0, 0.0 } };

	const int n = int(quality);
	for (int i = 0; i < n; i++) {
		color[0] += pick_color(v[0] + center).ra;
		color[1] += pick_color(v[1] + center).ga;
		color[2] += pick_color(v[2] + center).ba;
		for (int k = 0; k < 3; k++) {
			v[k] = mul(mat_d[k], v[k] + d[k]); d[k] = mul(mat_d[k], d[k]);
		}
	}

	float3
		col = float3(color[0].x, color[1].x, color[2].x) / quality,
		alp = float3(color[0].y, color[1].y, color[2].y) / quality;
	const float alpha = dot(alp, 1) / 3;
	if (mode_blend > 0) col = (alp > 0 ? col / alp : 0) * alpha;
	else col = min(col, 1);
	return float4(col, alpha);
}
