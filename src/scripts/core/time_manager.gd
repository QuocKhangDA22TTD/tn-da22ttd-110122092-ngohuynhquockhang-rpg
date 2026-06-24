extends Node

# LƯU Ý NHỚ ĐỌC QUY ƯỚC NÀY TRƯỚC:

# total_minutes là biến lưu tổng số phút từ mốc 00:00 đến 24:00.
# - 60 phút = 1 giờ.
# - 1440 phút = 1 ngày.
#
# Mặc định game bắt đầu lúc 06:00 :
# - 6 * 60 = 360 phút.
#
# Time_scale quyết định tốc độ thời gian, ví dụ:
# - 60  => 1 giây thực = 1 phút game
# - 120 => 1 giây thực = 2 phút game
#
# Các hệ thống khác (UI, NPC, ánh sáng, sự kiện...)
# nên lắng nghe signal thay vì tự kiểm tra thời gian.

signal minute_changed(minute: int)
signal hour_changed(hour: int)
signal day_changed(day: int)
signal period_changed(period: DayPeriod)

enum DayPeriod {
	DAWN,
	MORNING,
	AFTERNOON,
	EVENING,
	NIGHT
}

@export var time_scale := 60.0 # Tốc độ thời gian trong game, 1 giây ngoài đời bằng 1 phút trong game

var total_minutes: int = 360 # Tổng số phút tính từ 0 giờ tới 24 sẽ là 1440 phút, đặt mặc định 360 để bắt đầu lúc 6 giờ sáng

var _time_accumulator := 0.0 # Bộ tích lũy thời gian thực

var current_period := DayPeriod.MORNING # Trạng thái buổi hiện tại

func _process(delta):
	_time_accumulator += delta * time_scale # Tích lũy thời gian thực bằng cách nhân delta với time_scale

	while _time_accumulator >= 60.0:
		_time_accumulator -= 60.0 # Nếu quá 60 giây thì reset lại _time_accumulator để chuyển sang phút kế tiếp
		_advance_minute() # Gọi hàm _advance_minute để tăng lên 1 phút


func _advance_minute():
	total_minutes += 1 # Tăng lên 1 phút

	minute_changed.emit(get_minute()) # Gọi signal thông báo thay đổi phút

	if get_minute() == 0:
		hour_changed.emit(get_hour()) # Nếu phút bằng 0 thì gọi signal để thông báo thay đổi giờ

	if total_minutes >= 1440:
		total_minutes = 0 # Nếu như số phút lớn hơn 1440 thì reset lại về 0, vì đã qua 24 giờ, nghĩa là qua 1 ngày
		day_changed.emit(1) # Gọi signal thông báo thay đổi ngày

	_check_period_change() # Kiểm tra có đổi buổi không


func get_hour() -> int:
	return total_minutes / 60 # Trả về số giờ kiểu số nguyên


func get_minute() -> int:
	return total_minutes % 60 # Trả về số phút kiểu số nguyên


func get_time_string() -> String:
	# Trả về chuỗi định dạng giờ:phút (HH:MM)
	return "%02d:%02d" % [
		get_hour(),
		get_minute()
	]


func get_period() -> DayPeriod:

	var hour := get_hour() # Lấy giờ hiện tại

	if hour >= 5 and hour < 7:
		return DayPeriod.DAWN # Nếu như trên 5 giờ và dưới 7 giờ thì trả về buổi bình minh

	if hour >= 7 and hour < 12:
		return DayPeriod.MORNING # Nếu như trên 7 giờ và dưới 12 giờ thì trả về buổi sáng

	if hour >= 12 and hour < 17:
		return DayPeriod.AFTERNOON # Nếu như trên 12 giờ và dưới 17 giờ thì trả về buổi trưa

	if hour >= 17 and hour < 20:
		return DayPeriod.EVENING # Nếu như trên 17 giờ và dưới 20 giờ thì trả về buổi chiều

	return DayPeriod.NIGHT # Nếu như trên 20 giờ thì trả về buổi tối


func _check_period_change():

	var new_period := get_period() # Lấy buổi hiện tại

	if new_period != current_period:
		# Nếu như buổi vừa mới lấy được khác với buổi đang lưu trong biến current_period
		# thì gán buổi mới lấy vào biến current_period
		current_period = new_period
		period_changed.emit(current_period) # Gọi signal thông báo thay đổi buổi
