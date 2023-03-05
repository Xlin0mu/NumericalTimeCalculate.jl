module NumericalTime
export Majortime, NumericalTime

using Dates

global timeperiods_dict = Dict([(Nanosecond, 1), (Microsecond, 2), (Millisecond, 3), (Second, 4),  (Minute, 5), (Hour, 6)])
global timeperiods = (Nanosecond, Microsecond, Millisecond, Second, Minute, Hour)

abstract type NumericalTime end

"""
提供可以数值运算的时间结构，但去除了毫秒及更高精度的单位，转而提升了总时间上限
"""
struct Majortime <: NumericalTime
    hour :: Hour
    minute :: Minute
    second :: Second
    function Majortime(h::Hour, m::Minute, s::Second)
        a = [h.value, m.value, s.value]
        a[2] += a[3]÷60
        a[3] %= 60
        a[1] += a[2]÷60
        a[2] %= 60
        return new(Hour(a[1]), Minute(a[2]), Second(a[3]))
    end
end

"""
全参的int类型创建方法
"""
function Majortime(h::Int, m::Int, s::Int)
    a = [h, m, s]
    a[2] += a[3]÷60
    a[3] %= 60
    a[1] += a[2]÷60
    a[2] %= 60
    Majortime(Hour(a[1]), Minute(a[2]), Second(a[3]))
end

"""
方便的使用int数组创建
"""
function Majortime(x...)
    length(x) > 3 ? throw(ArgumentError("too many inputs")) : nothing
    if length(x) == 3
        Majortime(x...)
    elseif length(x) == 2
        Majortime(0, x...)
    else
        Majortime(0, 0, x...)
    end
end

"""
允许Majortime类型的数值运算
"""
function Base.:+(t1 :: Majortime, t2 :: Majortime)
    return Majortime(
        t1.hour + t2.hour,
        t1.minute + t2.minute,
        t1.second + t2.second
    )
end

"""
未测试！！！
"""
function Base.:-(t1 :: Majortime, t2 :: Majortime)
    return Majortime(
        t1.hour - t2.hour,
        t1.minute - t2.minute,
        t1.second - t2.second
    )
end

"""
Time的数值版本, 允许加减运算
numerical time type, plus/subtract operation allowed.
"""
struct NTime <: NumericalTime
    majortime :: Majortime
    minortime :: Time
end

"""
允许类似Time的创建方式
"""
function NTime(period::TimePeriod)
    return NTime(Time(period))
end

"""
允许类似Time的创建方式
"""
function NTime(periods::TimePeriod...)
    return sum(NTime.(Time.(periods)))
end

"""
Construct a NumericalTime type by parts. Arguments must be Int64.
last number is considering as second by default.
"""
function NTime(x::Int...; base = Second)
    timeperiods_dict[base] + length(x) > 6 ? throw(ArgumentError("too many inputs")) : nothing
    x = Union{TimePeriod, Int}[reverse(x)...]
    j = 1
    for i in timeperiods_dict[base] : timeperiods_dict[base] + length(x)-1
        x[j] = timeperiods[i](x[j])
        j += 1;
    end
    return NTime(x...)
end

"""
Create a NumericalTime object by string
"""
function NTime(str :: String)
    time_vector = str2num.(split(str, ':'))
    if length(time_vector) == 1
        NTime(0, 0, Second(time_vector[1]))
    elseif length(time_vector) == 2
        NTime(0, Minute(time_vector[1]), Second(time_vector[2]))
    elseif length(time_vector) == 3
        NTime(Hour(time_vector[1]), Minute(time_vector[2]), Second(time_vector[3]))
    end
end

#添加运算
function Base.:+(t1 :: NTime, t2 :: NTime)
    return NTime(Nanosecond(t1.time.instant.value + t2.time.instant.value))
end

#警告！
#存在数值溢出情况！
function Base.:+(t1 :: NTime, t2 :: NTime)
    return NTime(Nanosecond(t1.time.instant.value - t2.time.instant.value))
end

function Time(time :: NTime)
    return time.time
end

end