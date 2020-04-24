const box_size = 30;

class OneStroke {
	constructor(step_count) {
		this._step_count = step_count;
		this.reset();
	}

	reset() {
		// フィールド作成用
		this.tmp_left = 0;
		this.tmp_top = 0;

		this.min_left = 0;
		this.min_top = 0;

		this.boxes = [];
		this.boxes.push([this.tmp_left, this.tmp_top]);

		// ゲーム進行用
		this.move_history = [];

		this._start_x = null;
		this._start_y = null;
		this._tap_start_pos = null;
	}

	set step_count(step_count) {
		this._step_count = step_count;
	}

	get step_count() {
		return this._step_count;
	}

	set tap_start(box) {
		this._start_x = box == null ? null : box.offset().left;
		this._start_y = box == null ? null : box.offset().top;
	}

	get tap_start() {
		return `${this._start_x},${this._start_y}`
	}

	set tap_start_pos(box) {
		this._tap_start_pos = box == null ? null : box.attr("pos");
	}

	get tap_start_pos() {
		return this._tap_start_pos;
	}

    /**
     * エリア作成
     */
	create_field() {
		this.reset();
		$(".boxes").empty();
		for (var i = 0; i < this.step_count; i++) {
			if (!this.check_add_able()) {
				// 上下左右置き場所がないときはリセットして作り直す。
				i = -1;
				this.reset();
				continue;
			}
			this.add_box();
		}
		this.adjuest();

		// 画面表示
		var i = 0;
		for (let box_position of this.boxes) {
			var box = $(`<div class="box" pos="${box_position[0]},${box_position[1]}">`);
			if (i == 0) {
				box.addClass("selected");
			}
			box.offset({top: box_position[1] * box_size, left: box_position[0] * box_size});
			$(".boxes").append(box);
			i ++;
		}
	}

	/**
	 * 上下左右に箱を作れる場所があるか確認する。
	 * true: 作れる
	 * false: 作れない
	 */
	check_add_able() {
		var pos = this.boxes[this.boxes.length - 1];
		if (this.exists_array([pos[0] - 1, pos[1]], this.boxes) &&
			this.exists_array([pos[0] + 1, pos[1]], this.boxes) &&
			this.exists_array([pos[0] , pos[1] - 1], this.boxes) &&
			this.exists_array([pos[0] , pos[1] + 1], this.boxes)) {
			return false;
		} else {
			return true;
		}
	}

	/**
	 * 上下左右いずれかランダムに箱を作る。
	 */
	add_box() {
		var pos = this.boxes[this.boxes.length - 1];
		while (this.exists_array([this.tmp_left, this.tmp_top], this.boxes)) {
			var move_param = Math.ceil(Math.random() * 4);
			this.tmp_left = pos[0];
			this.tmp_top = pos[1];
			
			if (move_param == 1) {
				this.tmp_left--;
			} else if (move_param == 2) {
				this.tmp_left++;
			} else if (move_param == 3) {
				this.tmp_top--;
			} else if (move_param == 4) {
				this.tmp_top++;
			}
		}
		this.boxes.push([this.tmp_left, this.tmp_top]);
		pos = this.boxes[this.boxes.length - 1];
		if (this.min_left > pos[0]) {
			this.min_left = pos[0];
		}
		if (this.min_top > pos[1]) {
			this.min_top = pos[1];
		}
	}

	/**
	 * indexOfを配列で実現
	 * 第二引数：[[a,b], [c,d]]
	 * 第一引数が
	 * [a,b] の場合true
	 * [c,d] の場合true
	 * [b,a] の場合false
	 */
	exists_array(target, arrays) {
		for (let array of arrays) {
			if (target.length != array.length) {
				continue;
			}

			var flg = true;
			for (var i = 0; i < array.length; i++) {
				if (array[i] != target[i]) {
					flg = false;
					break;
				}
			}
			if (flg == true) {
				return true;
			} else {
				continue;
			}
		}
		return false;
	}

	/**
	 * 追加していった箱の座標の最低値を0にする。
	 */
	adjuest() {
		for (var i = 0; i < this.boxes.length; i++) {
			this.boxes[i][0] = this.boxes[i][0] - this.min_left;
			this.boxes[i][1] = this.boxes[i][1] - this.min_top;
		}
		this.init_pos = `${this.boxes[0][0]},${this.boxes[0][1]}`;
		this.now_pos = this.init_pos;
		this.move_history.push(this.now_pos);
	}

	/**
	 * ゲーム進行用
	 */
	move(box) {
		var result = false;
		if (this.check_move_able(box)) {
			this.move_history.push(box.attr("pos"));
			box.addClass("selected");
			result = true;
		} else if (this.check_back_able(box)) {
			this.move_history.pop();
			box.removeClass("selected");
			result = true;
		} else if (this.check_retun_able(box)) {
			this.box_return(box);
			result = true;
		}

		if (this.step_count == $("div.box.selected").length - 1) {
			$(".boxes").html($("<div>").html("クリア！"));
			var btn = $("<button class='next'>").html("next");
			$(".boxes").append(btn);
		}
		return result;
	}

	/**
	 * 現在位置の上下左右であることを確認する。
	 * 進めることの確認
	 */
	check_move_able(box) {
		// 選択したマス
		var next_pos = box.attr("pos");
		// 現在の位置
		var pos = this.move_history[this.move_history.length - 1].split(",");

		if ((next_pos == `${Number(pos[0]) + 1},${Number(pos[1])}` ||
			 next_pos == `${Number(pos[0]) - 1},${Number(pos[1])}` ||
			 next_pos == `${Number(pos[0])},${Number(pos[1]) + 1}` ||
			 next_pos == `${Number(pos[0])},${Number(pos[1]) - 1}`
			) && !box.hasClass("selected")) {
			return true;
		}
		return false;
	}

	/**
	 * 一つ前の箱かを確認する。
	 * 洗濯済み、または初期位置の場合除外
	 * 戻れることの確認
	 */
	check_back_able(box) {
		// 選択したマス
		var back_pos = box.attr("pos");
		var now_pos = this.move_history[this.move_history.length - 1];
		var init_pos = this.move_history[0];
		if (back_pos == now_pos && back_pos != init_pos && box.hasClass("selected")) {
			return true;
		}
		return false;
	}

	check_retun_able(box) {
		// 選択したマス
		if (box.hasClass("selected")) {
			return true;
		}
	}

	box_return(box) {
		var return_pos = box.attr("pos");

		for (let i = this.move_history.length - 1; i >= 0; i--) {
			var history_box = this.move_history[i];
			if (history_box == return_pos) {
				break;
			}
			if (history_box != this.move_history[0]) {
				$(`div[pos='${history_box}']`).removeClass("selected");
				this.move_history.pop();
			}
		}
	}
}