class SnippetsController < ApplicationController
  before_action :set_snippet, only: %i[edit update destroy]

  def index
    @snippets = policy_scope(Snippet).active_snippets.order(:title)
    @snippets = @snippets.by_category(params[:category]) if params[:category].present?
  end

  def new
    @snippet = Snippet.new
    authorize @snippet
  end

  def edit
    authorize @snippet
  end

  def create
    @snippet = Snippet.new(snippet_params)
    authorize @snippet

    if @snippet.save
      redirect_to snippets_path, notice: 'Snippet criado.'
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    authorize @snippet

    if @snippet.update(snippet_params)
      redirect_to snippets_path, notice: 'Snippet atualizado.'
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @snippet
    @snippet.destroy
    redirect_to snippets_path, notice: 'Snippet removido.'
  end

  private

  def set_snippet
    @snippet = Snippet.find(params.expect(:id))
  end

  def snippet_params
    params.expect(snippet: %i[title content category])
  end
end
