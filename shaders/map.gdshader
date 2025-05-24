shader_type spatial;
render_mode unshaded;

varying vec3 world_pos;

uniform sampler2D positions;

uniform sampler2D colors : source_color;

uniform sampler2D noise;

uniform bool enabled;

float handle_point(vec2 point, float radius) {
	float tentative_magnitude = 1.0f - (distance(point, world_pos.xz) / radius);
	tentative_magnitude = smoothstep(0.0f, 1.0f, tentative_magnitude);

	return tentative_magnitude;
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	ivec2 size = textureSize(positions, 0);

	float magnitude = 0.0f;
	//
	//vec3 closest_point_color = vec3(0.0f, 0.1f, 1.0f);
	//float closest_point_distance = -1.0f;
	//
	//vec3 closest_point_colors[3] = {vec3(0.0f, 1.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f)};
	//float closest_point_distances[3] = {-0.01f, -0.01f, -0.01f};
	//vec2 closest_points[3] = {vec2(0.0f, 1.0f), vec2(-1.0f, 0.0f), vec2(1.0f, 0.0f)};
	//
	float weight_sum = 0.0f;
	vec3 color_sum = vec3(0.0f, 0.0f, 0.0f);
	vec3 color = vec3(0.0f, 0.1f, 1.0f);

	for (int i = 0; i < size.x; i++) {
		vec4 texel = texelFetch(positions, ivec2(i, 0), 0);
		vec2 point = texel.rg;
		vec3 point_color = vec3(0.0f, 1.0f, 0.1f);

		float radius = 2.0f;

		magnitude += handle_point(point, radius);

		if (texel.b >= 1.0f) {
			point_color = texelFetch(colors, ivec2(i, 0), 0).rgb;

			float dist = distance(world_pos.xz, point);

			float weight = 1.0f / pow(dist, 7.0f);

			weight_sum += weight;

			color_sum += point_color * weight;

			//color = point_color;
		}

		//if (dist < closest_point_distances[0] || closest_point_distances[0] <= 0.0f) {
			//closest_point_distances[2] = closest_point_distances[1];
			//closest_point_distances[1] = closest_point_distances[0];
			//closest_point_distances[0] = dist;
			//
			//closest_point_colors[2] = closest_point_colors[1];
			//closest_point_colors[1] = closest_point_colors[0];
			//closest_point_colors[0] = point_color;
			//
			//closest_points[2] = closest_points[1];
			//closest_points[1] = closest_points[0];
			//closest_points[0] = point;
			//continue;
		//}
		//
		//if (dist < closest_point_distances[1] || closest_point_distances[1] <= 0.0f) {
			//closest_point_distances[2] = closest_point_distances[1];
			//closest_point_distances[1] = dist;
			//
			//closest_point_colors[2] = closest_point_colors[1];
			//closest_point_colors[1] = point_color;
			//
			//closest_points[2] = closest_points[1];
			//closest_points[1] = point;
			//continue;
		//}
		//
		//if (dist < closest_point_distances[2] || closest_point_distances[2] <= 0.0f) {
			//closest_point_distances[2] = dist;
			//
			//closest_point_colors[2] = point_color;
			//
			//closest_points[2] = point;
			//continue;
		//}
	}


	magnitude += texture(noise, UV).r * 0.3;

	magnitude = clamp(magnitude, 0.0f, 1.0f);

	if (magnitude > 0.5f && enabled) {
		//float[3] weights = get_barycentric_weights(world_pos.xz, closest_points[0], closest_points[1], closest_points[2]);
		//
		//weights[0] = clamp(weights[0], 0.0f, 1.0f);
		//weights[1] = clamp(weights[1], 0.0f, 1.0f);
		//weights[2] = clamp(weights[2], 0.0f, 1.0f);
		//
		//color = (closest_point_colors[0] * weights[0]) + (closest_point_colors[1] * weights[1]) + (closest_point_colors[2] * weights[2]);

		//color = vec3(0.0f, 1.0f, 0.1f);
		color = color_sum / weight_sum;
	}
	ALBEDO = color;
}