module Subprocessor
  def within_subprocess(&block)
    subprocess = Process.fork  do
      connect_asyncronous_pipe
      yield
    end
    Process.detach(subprocess)
  end
end
