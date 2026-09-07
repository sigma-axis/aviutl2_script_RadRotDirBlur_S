--information:RadRotDirBlur_S ${PACKAGE_VERSION} by ${AUTHOR}
---$nolang: script_name
---$script_tips:放射ブラー，回転ブラー，方向ブラーの 3 つを複合したぼかし効果．
--label:ぼかし
--filter
--require:${LEAST_AVIUTL_VERSION}
---$tips:方向ブラーの方向
---$track:移動X, min = -4000, max = 4000, step = 0.01, scale = 0.25
local dir_x = 0

---$tips:方向ブラーの方向
---$track:移動Y, min = -4000, max = 4000, step = 0.01, scale = 0.25
local dir_y = 0

--trackgroup@dir_x,dir_y:directional
---$tips:放射ブラーの拡大率
---$track:拡大率, min = 1, max = 10000, step = 0.001, scale = 0.02
local rad = 100

---$tips:回転ブラーの回転角
---$track:回転角, min = -3600, max = 3600, step = 0.01, scale = 0.1
local rot = 0

---$tips:放射ブラーと回転ブラーの中心
---$track:中心X, min = -4000, max = 4000, step = 0.01, scale = 0.25
local cx = 0

---$tips:放射ブラーと回転ブラーの中心
---$track:中心Y, min = -4000, max = 4000, step = 0.01, scale = 0.25
local cy = 0

--trackgroup@cx,cy:center_of_blur
---$checksection:回転中心を基準
local center_based = false

--hide@center_based:filter~=0
---$track:強さ, min = -1000, max = 1000, step = 0.01, scale = 0.2
local amount = 100

---$track:相対位置, min = -100, max = 100, step = 0.01
local rel_pos = 0

--group:色収差設定,false
---$tips:現実世界の正しい順序は「赤青」．A は B より半透明部分が減衰しやすい．
---$select:色収差
---赤青A = 0
---赤緑A = 1
---緑青A = 2
---赤青B = 3
---赤緑B = 4
---緑青B = 5
local chroma = 3

---$track:色収差強さ, min = -100, max = 100, step = 0.01
local chrm_abrr = 0

--group
---$checksection:サイズ固定
local keep_size = false

--hide@keep_size:filter~=0
--group:その他,false
---$tips:ぼかし計算のサンプル数
---$track:精度, min = 2, max = 4096, step = 1, scale = 0.25
local quality = 512

---$nolang: name
---$tips:PI = {
---     :  dir: table? { x, y },
---     :  rad: number?,
---     :  rot: number?,
---     :  center: table? { x, y },
---     :  center_based: boolean|number|nil,
---     :  amount: number?,
---     :  rel_pos: number?,
---     :  chroma: string?,
---     :  chrm_abrr: number?,
---     :  keep_size: boolean|number|nil,
---     :  quality: number?,
---     :}
---$value:PI
local PI = {}

--group:互換対応(将来削除予定),false
---$value:中心
local center = {}

--[[pixelshader@apply:
---$include "apply.hlsl"
]]
--[[pixelshader@apply_chroma:
---$include "apply_chroma.hlsl"
]]

local obj, tonumber, type, math = obj, tonumber, type, math;

-- set anchors.
if obj.getoption("gui") then
	local center_x, center_y = 0, 0;
	if center_based then
		center_x, center_y = obj.getvalue("center");
		center_x, center_y = center_x + obj.cx, center_y + obj.cy;
	end
	obj.setanchor("cx,cy", 0, "line", "offset", center_x, center_y, "rgba", 0x208020c0);
	obj.setanchor("dir_x,dir_y", 0, "line", "offset", center_x, center_y, "rgba", 0xf05050c0);
	obj.setanchor({ 0, 0, dir_x, dir_y }, 2, "line", "offset", center_x, center_y, "color", 0xf05050);
end

-- take parameters.
local function as_bool(t, v)
	if type(t) == "boolean" then return t;
	elseif type(t) == "number" then return t ~= 0;
	else return v end
end
if type(PI.dir) == "table" then
	dir_x = tonumber(PI.dir[1]) or dir_x;
	dir_y = tonumber(PI.dir[2]) or dir_y;
end
rad = tonumber(PI.rad) or rad;
rot = tonumber(PI.rot) or rot;
cx, cy = tonumber(center[1]) or cx, tonumber(center[2]) or cy; -- legacy compatibility.
if type(PI.center) == "table" then
	cx = tonumber(PI.center[1]) or cx;
	cy = tonumber(PI.center[2]) or cy;
end
center_based = as_bool(PI.center_based, center_based) and not obj.getinfo("filter");
amount = tonumber(PI.amount) or amount;
rel_pos = tonumber(PI.rel_pos) or rel_pos;
if PI.chroma then
	local name2num = {
		[0] = 0, 1, 2, 3, 4, 5; -- legacy compatibility.
		["赤青A"] = 0, ["赤緑A"] = 1, ["緑青A"] = 2,
		["赤青B"] = 3, ["赤緑B"] = 4, ["緑青B"] = 5,
	};
	chroma = name2num[PI.chroma] or chroma;
end
chrm_abrr = tonumber(PI.chrm_abrr) or chrm_abrr;
keep_size = as_bool(PI.keep_size, keep_size) or obj.getinfo("filter");
quality = tonumber(PI.quality) or quality;

-- normalize paramters.
rad = math.max(rad / 100, 0.01);
rot = rot * math.pi / 180;
if center_based then
	local x, y = obj.getvalue("center");
    cx, cy = cx + x + obj.cx, cy + y + obj.cy;
end
amount = amount / 100;
rel_pos = math.min(math.max(rel_pos / 100, -1), 1);
chroma = math.min(math.max(math.floor(0.5 + chroma), 0), 5);
chrm_abrr = math.min(math.max(chrm_abrr / 100, -1), 1);
quality = math.min(math.max(math.floor(0.5 + quality), 2), 4096);

if amount == 0 or (rad == 1 and rot == 0 and dir_x == 0 and dir_y == 0) then return end

-- erase amount.
rad = rad ^ amount;
rot = rot * amount;
dir_x = dir_x * amount;
dir_y = dir_y * amount;

-- calculation of bounding boxes.
local function union_rect(l, t, r, b, L, T, R, B)
	return math.min(l, L), math.min(t, T), math.max(r, R), math.max(b, B);
end
local function arc_bound_core2(R, A, a, a2, ...)
	if A < 0 then
		local l, t, r, b = arc_bound_core2(R, A + math.pi, a, a2, ...);
		return -r, -b, -l, -t;
	elseif A > math.pi / 2 then
		local l, t, r, b = arc_bound_core2(R, A - math.pi / 2, a, a2, ...);
		return -b, l, -t, r;
	elseif a2 then
		local l, t, r, b = arc_bound_core2(R, A, a);
		return union_rect(l, t, r, b, arc_bound_core2(R, A, a2, ...));
	elseif a < 0 then
		local l, t, r, b = arc_bound_core2(R, math.pi / 2 - A, -a)
		return t, l, b, r;
	end

	a = a + A;
	local l, t, r, b = -R, -R, R, R;
	if a < 0.5 * math.pi then b = R * math.sin(a) end
	if a < 1.0 * math.pi then l = R * math.cos(a) end
	if a < 1.5 * math.pi then t = R * math.sin(a) end
	if a < 2.0 * math.pi then r = R * math.cos(a) end
	return l, t, r, b;
end
local function arc_bound_core(x, y, ...)
	return arc_bound_core2((x ^ 2 + y ^ 2) ^ 0.5, math.atan2(y, x), ...);
end
local function arc_bound(left, top, right, bottom, ...)
	local l, t, r, b = arc_bound_core(left, top, ...);
	l, t, r, b = union_rect(l, t, r, b, arc_bound_core(right, top, ...));
	l, t, r, b = union_rect(l, t, r, b, arc_bound_core(right, bottom, ...));
	return union_rect(l, t, r, b, arc_bound_core(left, bottom, ...));
end

local function calc_extra_size(width, height, scale1, rotate1, move_x1, move_y1, scale2, rotate2, move_x2, move_y2, center_x, center_y)
	-- find the final bounding box.
	local l, t, r, b =
		-width / 2 - center_x, -height / 2 - center_y,
		width / 2 - center_x, height / 2 - center_y;

	-- possible inflation by rotation.
	l, t, r, b = union_rect(l, t, r, b,
		arc_bound(l, t, r, b, rotate1, rotate2));

	-- possible inflation by scaling.
	l, t, r, b = union_rect(l, t, r, b, scale1 * l, scale1 * t, scale1 * r, scale1 * b);
	l, t, r, b = union_rect(l, t, r, b, scale2 * l, scale2 * t, scale2 * r, scale2 * b);

	-- possible inflation by movement.
	l = l + math.min(move_x1, move_x2);
	t = t + math.min(move_y1, move_y2);
	r = r + math.max(move_x1, move_x2);
	b = b + math.max(move_y1, move_y2);

	-- calculate and return the extra size required.
	return
		math.ceil(math.max(0, -l - center_x - width / 2)),
		math.ceil(math.max(0, -t - center_y - height / 2)),
		math.ceil(math.max(0, r + center_x - width / 2)),
		math.ceil(math.max(0, b + center_y - height / 2));
end

local function transform_info(p1, p2)
	return {
		scale1  = rad   ^ p1, scale2  = rad   ^ p2,
		rotate1 = rot   * p1, rotate2 = rot   * p2,
		move_x1 = dir_x * p1, move_x2 = dir_x * p2,
		move_y1 = dir_y * p1, move_y2 = dir_y * p2,

		scale_d = rad ^ ((p2 - p1) / (quality - 1)),
		rotate_d = rot * (p2 - p1) / (quality - 1),
		move_x_d = dir_x * (p2 - p1) / (quality - 1),
		move_y_d = dir_y * (p2 - p1) / (quality - 1),
	};
end

-- calculate the beggining and ending states.
local w, h = obj.w, obj.h;
local rel_pos1, rel_pos2 = (rel_pos - 1) / 2, (rel_pos + 1) / 2;
local info, offset_x, offset_y = transform_info(rel_pos1, rel_pos2), 0, 0;

-- expand the canvas unless specified.
local cache_name = "cache:radrotdirblur_s/obj";
obj.copybuffer(cache_name, "object");
if not keep_size then
	local l, t, r, b = calc_extra_size(w, h,
		info.scale1, info.rotate1, info.move_x1, info.move_y1,
		info.scale2, info.rotate2, info.move_x2, info.move_y2, cx, cy);

	-- cap to the maximum size of images.
	local max_w, max_h = obj.getinfo("image_max");
	if l + r + w > max_w then
		local diff = (l + r + w - max_w) / 2;
		l, r = l - math.ceil(diff), r - math.floor(diff);
		if l < 0 then l, r = 0, r + l end
		if r < 0 then l, r = l + r, 0 end
	end
	if t + b + h > max_h then
		local diff = (t + b + h - max_h) / 2;
		t, b = t - math.ceil(diff), b - math.floor(diff);
		if t < 0 then t, b = 0, b + t end
		if b < 0 then t, b = t + b, 0 end
	end

	-- expand the canvas and reposition the coordinates.
	obj.clearbuffer("object", l + obj.w + r, t + obj.h + b);
	obj.cx, obj.cy = obj.cx + (l - r) / 2, obj.cy + (t - b) / 2;
	offset_x, offset_y = l, t;
end

if chrm_abrr == 0 then
	-- apply the shader.
	obj.pixelshader("apply", "object", cache_name,
	{
		math.cos(-info.rotate_d) / info.scale_d, math.sin(-info.rotate_d) / info.scale_d;
		math.cos(-info.rotate1) / info.scale1, math.sin(-info.rotate1) / info.scale1;
		-info.move_x_d / w, -info.move_y_d / h;
		-(info.move_x1 + offset_x) / w, -(info.move_y1 + offset_y) / h;

		cx / w + 0.5, cy / h + 0.5; w, h;
		quality;
	}, "copy", keep_size and "clamp" or "clip");
else
	-- prepare transforms for each color component.
	local t2, t3 = 1 - chrm_abrr ^ 2 / 2, 1 - chrm_abrr ^ 2;
	local infos = {
		transform_info(rel_pos1 * t3, rel_pos2 * t3),
		transform_info(rel_pos1 * t2, rel_pos2 * t2),
		info,
	};

	-- re-order the color components.
	if chrm_abrr < 0 then infos[1], infos[3] = infos[3], infos[1] end
	local mode_blend = chroma >= 3; if mode_blend then chroma = chroma - 3 end
	if chroma == 0 then -- nothing.
	elseif chroma == 1 then infos[2], infos[3] = infos[3], infos[2];
	elseif chroma == 2 then infos[1], infos[2] = infos[2], infos[1] end

	-- apply the shader.
	obj.pixelshader("apply_chroma", "object", cache_name,
	{
		math.cos(-infos[1].rotate_d) / infos[1].scale_d, math.sin(-infos[1].rotate_d) / infos[1].scale_d;
		math.cos(-infos[2].rotate_d) / infos[2].scale_d, math.sin(-infos[2].rotate_d) / infos[2].scale_d;
		math.cos(-infos[3].rotate_d) / infos[3].scale_d, math.sin(-infos[3].rotate_d) / infos[3].scale_d;

		math.cos(-infos[1].rotate1) / infos[1].scale1, math.sin(-infos[1].rotate1) / infos[1].scale1;
		math.cos(-infos[2].rotate1) / infos[2].scale1, math.sin(-infos[2].rotate1) / infos[2].scale1;
		math.cos(-infos[3].rotate1) / infos[3].scale1, math.sin(-infos[3].rotate1) / infos[3].scale1;

		-infos[1].move_x_d / w, -infos[1].move_y_d / h;
		-infos[2].move_x_d / w, -infos[2].move_y_d / h;
		-infos[3].move_x_d / w, -infos[3].move_y_d / h;

		-(infos[1].move_x1 + offset_x) / w, -(infos[1].move_y1 + offset_y) / h;
		-(infos[2].move_x1 + offset_x) / w, -(infos[2].move_y1 + offset_y) / h;
		-(infos[3].move_x1 + offset_x) / w, -(infos[3].move_y1 + offset_y) / h;

		cx / w + 0.5, cy / h + 0.5; w, h;
		quality; mode_blend and 0 or 1;
	}, "copy", keep_size and "clamp" or "clip");
end
