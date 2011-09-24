module Subprocessor
  def within_subprocess(&block)
    subprocess = Process.fork  do
      yield
    end
    Process.detach(subprocess)
  end
end
