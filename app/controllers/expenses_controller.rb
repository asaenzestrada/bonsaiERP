# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ExpensesController < ApplicationController

  before_filter :check_authorization!
  before_filter :set_currency_rates, :only => [:index, :show]
  before_filter :set_transaction, :only => [:show, :edit, :update, :destroy, :approve]

  #respond_to :html, :xml, :json
  # GET /buys
  # GET /buys.xml
  def index
    if params[:search].present?
      @expenses = Expense.search(params).page(@page)
    else
      @expenses = Expense.find_with_state(params[:option]).page(@page)
    end
  end

  # GET /buys/1
  # GET /buys/1.xml
  def show
    respond_to do |format|
      format.html { render 'transactions/show' }
      format.xml  { render :xml => @transaction }
    end
  end

  # GET /buys/new
  # GET /buys/new.xml
  def new
    @transaction = Expense.new(:date => Date.today, :discount => 0, :currency_exchange_rate => 1, :currency_id => currency_id )
    @transaction.transaction_details.build
  end

  # GET /buys/1/edit
  def edit
    if @transaction.state == 'approved'
      flash[:warning] = "No es posible editar una nota de gasto aprobada"
      redirect_to @transaction
    end
  end


  # POST /buys
  # POST /buys.xml
  def create
    @transaction = Expense.new(params[:expense])

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to(@transaction, :notice => 'Se ha creado una nota de gasto.') }
        format.xml  { render :xml => @transaction, :status => :created, :location => @transaction }
      else
        @transaction.transaction_details.build unless @transaction.transaction_details.any?
        format.html { render :action =>  "new" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /buys/1
  # PUT /buys/1.xml
  def update
    if @transaction.approved?
      redirect_transaction
    else
      if @transaction.update_attributes(params[:expense])
        redirect_to @transaction, :notice => 'La proforma de gasto fue actualizada!.'
      else
        @transaction.transaction_details.build unless @transaction.transaction_details.any?
        render :action => "edit"
      end
    end
  end

  # DELETE /buys/1
  # DELETE /buys/1.xml
  def destroy
    @transaction.destroy
  end

  # PUT /buys/1/approve
  # Method to approve an income
  def approve
    if @transaction.approve!
      flash[:notice] = "El gasto fue aprobado"
    else
      flash[:error] = "Existio un problema con la aprovación"
    end

    anchor = ''
    anchor = 'payments' if @transaction.cash?

    redirect_to expense_path(@transaction, :anchor => anchor)
  end
private
  def set_currency_rates
    @currency_rates = CurrencyRate.current_hash
  end

  def set_transaction
    @transaction = Expense.org.find(params[:id])
  end
end
