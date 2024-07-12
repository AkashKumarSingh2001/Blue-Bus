class ReservationsController < ApplicationController

    before_action :set_bus ,only: %i[create  show destroy ]
    before_action :authenticate_user! ,only: %i[create  destroy  new]
    
    def new
        if(params[:dateofjourney] == nil)
            params[:dateofjourney] = Date.today
        end
        @bus = Bus.find(params[:bus_id])
        # current_bus_reservations = @bus.reservations.where(dateofjourney:params[:dateofjourney])
        # if(current_bus_reservations.size != 0)
        #     @booked_seat = current_bus_reservations.joins(:travellers).pluck('travellers.seat_id')
        # else
        #     @booked_seat = []
        # end
        # bus_seats = @bus.seats
        @reservation = @bus.reservations.new 
        # bus_seats.select do|seat|
        #     @reservation.travellers.new(seat_id:seat.seatno) if(@booked_seat.include?(seat.seatno) == false)
        # end
        #puts("no of seat to book #{params[:no_of_seats_to_book]== nil}")
    end

    #  def new 
    #     @bus = Bus.find(params[:bus_id])
    #     @reservation = @bus.reservations.new
    #     3.times { @reservation.travellers.build }
    #  end

    def index
        #fail
        bus = Bus.find(params[:bus_id])
        d_o_j = params[:dateofjourney]
        #puts("dateof journey is =  #{d_o_j}")
        @reservations = bus.reservations.where(dateofjourney:d_o_j)
    end

    def create
        #fail
        #variable to check whether error occured or not during reservation
        dateofjourney = params[:reservation][:dateofjourney]
        puts(params[:dateofjourney])
        selected_seats1 = params[:reservation][:selected_seats]
        puts(selected_seats1)
        if (selected_seats1.present? == false )
            flash[:alert]= "Please select more than 0 seats"
            redirect_back(fallback_location: root_path)
            return 
        end
        current_bus_reservations = @bus.reservations.where(dateofjourney:dateofjourney) #finding bus all resrvations

        #picking all travellers seat_id those seat which is booked for that date of journey 
        if(current_bus_reservations.size != 0 )
            @booked_seat = current_bus_reservations.joins(:travellers).pluck('travellers.seat_id').map(&:to_s)
        else
            @booked_seat= []
        end
        puts("Booked seats are:")
        puts(@booked_seat)
        if ((selected_seats1 & @booked_seat).any?)
            puts("Hello")
            flash[:alert] = "You cannot Book Already Booked Seat"
            redirect_back(fallback_location: root_path)
            return
        end
        #fail
        @reservation = @bus.reservations.new(reservation_params.merge(user_id:current_user.id))
        @reservation.save
        # ActiveRecord::Base.transaction do
        #     selected_seats1.each do|seatno|
        #         if (@booked_seat.size == 0 || @booked_seat.include?(seatno.to_i) == false)
        #             Traveller.create(seat_id:seatno.to_i,reservation_id:@reservation.id)
        #             flash[:notice] = "Reservation Done Successfully"
        #         else
        #             @reservation.delete
        #             errorduringres = 1 
        #             raise ActiveRecord::Rollback  # Rollback the transaction
        #         end
        #     end
        # end
        redirect_to "/buses/#{@bus.id}/reservations/#{@reservation.id}"
        return 
    end

    # def create
        #     @reservation = Reservation.new(reservation_params)
        #     fail
        #     if @reservation.save
        #       flash[:notice] = "reservation saved successfully"
        #     else
        #       render :new
        #     end
    # end    

    def show
        @seatid = []
        travellers = Traveller.where(reservation_id:params[:id])
        travellers.each do|traveler|
            puts("seat_id #{traveler.seat_id}")
            @seatid << traveler.seat_id
        end
        puts("seatno are#{@seatid.size}")
    end

    def destroy
        # findig resevaion whose id is mentioned in routes
        puts("destroy action of res")
        travcoll = Traveller.where(reservation_id:params[:id])

        #deleted all travellers who are under this reservation
        travcoll.delete_all
        #deleted specific registration
        res = Reservation.find(params[:id])
        res.destroy!
        flash[:notice] = "Reservations Deleted Successfully"
        redirect_back(fallback_location: root_path)
    end

    private
        def set_bus
            @bus = Bus.find(params[:bus_id])
        end


        def reservation_params
          params.require(:reservation).permit(:dateofjourney,[:selected_seats1],travellers_attributes: [:seat_id])
        end

end