require 'date'
class Periods_chain
  
    def initialize(start_date, periods)
      @start_date = start_date
      @periods = periods
    end

    def add_period(type, period)
        key = false
        case type
        when "daily"
          key = true if period =~ /^\d{4}M\d{1,2}D\d{1,2}$/
          begin
            Date.strptime(period, "%YM%mD%d")
          rescue 
            puts "Invalid period"
            return
          end
        when "monthly"
          key = true if period =~ /^\d{4}M\d{1,2}$/
        when "annually" 
          key = true if period =~ /^\d{4}$/
        else
          puts "Invalid period type"
          return
        end
    
        if key
          @periods << period
          puts "Period added: #{period}"
        else
          puts "Invalid period: #{period}"
        end
    end
    
    def print_periods
        puts @periods.to_s
    end

    def valid?
        puts calc
    end
    private

        def daily(start_date)
        start_date = Date.strptime(start_date, "%d.%m.%Y") if start_date.is_a?(String)
        end_date = start_date.next_day
        [end_date, 0]
        end
    
        def monthly(start_date)
        start_date = Date.strptime(start_date, "%d.%m.%Y") if start_date.is_a?(String)
        if start_date.month == 01 && (start_date.day == 30 || start_date.day == 31 || start_date.day == 29)
            $day_jan = start_date.day
        end
        if start_date.month == 02 && $day_jan == 31
            end_date = start_date.next_month.next_day(3)
        elsif start_date.month == 02 && $day_jan == 30
            end_date = start_date.next_month.next_day(2)
        elsif start_date.month == 02 && $day_jan == 29
            end_date = start_date.next_month.next_day(2)
        else
            end_date = start_date.next_month
        end
        [end_date, 0]
        end
    
        def annually(start_date)
        start_date = Date.strptime(start_date, "%d.%m.%Y") if start_date.is_a?(String)
        end_date = start_date.next_year
        [end_date, 0]
        end

        def calc
        date_start = Date.strptime(@start_date, "%d.%m.%Y")
        date_end = date_start
        @periods.each do |period|
            if period =~ /^\d{4}M\d{1,2}D\d{1,2}$/ && (date_start.year == Date.strptime(period, "%YM%mD%d").year &&
                                                       date_start.month == Date.strptime(period, "%YM%m").month && 
                                                       date_start.day == Date.strptime(period, "%YM%mD%d").day)
            date_start, date_end = daily(date_start)
            elsif period =~ /^\d{4}M\d{1,2}$/ && (date_start.year == Date.strptime(period, "%YM%m").year &&
                                                  date_start.month == Date.strptime(period, "%YM%m").month)
            date_start, date_end = monthly(date_start)
            elsif period =~ /^\d{4}$/ && (date_start.year == Date.strptime(period, "%Y").year)
            date_start, date_end = annually(date_start)
            else
            return false
            end
        end
        true
        end

  end

puts "  Проверка каждого примера "

all_periods = [["16.07.2023", ["2023", "2024", "2025"]],
               ["24.04.2023", ["2023", "2025", "2026"]],
               ["31.01.2023", ["2023M1", "2023M2", "2023M3"]],
               ["10.01.2023", ["2023M1", "2023M3", "2023M4"]],
               ["04.06.1976", ["1976M6D4", "1976M6D5", "1976M6D6"]],
               ["02.05.2023", ["2023M5D2", "2023M5D3", "2023M5D5"]],
               ["30.01.2023", ["2023M1", "2023M2", "2023M3D30"]],
               ["31.01.2023", ["2023M1", "2023M2", "2023M3D30"]],
               ["30.01.2020", ["2020M1", "2020", "2021", "2022", "2023", "2024M2", "2024M3D30"]],
               ["30.01.2020", ["2020M1", "2020", "2021", "2022", "2023", "2024M2", "2024M3D29"]]]
all_periods.each do |periods|
  dates = Periods_chain.new(periods[0], periods[1])
  dates.valid?
end

puts " Проверка добавления периода к концу цепочки "

start_date = "30.01.2023"
period = ["2023M1D30", "2023M1", "2023M2", "2023", "2024M3", "2024M4D30", "2024M5"]

date = Periods_chain.new(start_date, period)
date.valid?
date.add_period("monthly","2024M6")
date.valid?
