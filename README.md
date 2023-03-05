# NumericalTimeCalculate.jl
Allow calculating time data numerically.

(Unfinished !)

(Soon will be finished in 1~2 weeks)

## Structs

```julia
Majortime <: NumericalTime
  hour::Hour
  minute::Minute
  second::Second

NTime <: NumericalTime	#UnFinished
  majortime::Majortime
  minortime::Time
```

## Construct methods

```julia
julia>Majortime(Hour(1), Minute(2), Second(3))
Majortime(Hour(1), Minute(2), Second(3))

julia>Majortime(1,2,3)
Majortime(Hour(1), Minute(2), Second(3))

julia> Majortime(1,2)
Majortime(Hour(0), Minute(1), Second(2))
```

## Example

```julia
julia>Majortime(1,2,3)+Majortime(6,1,8)
Majortime(Hour(7), Minute(3), Second(11))
```

