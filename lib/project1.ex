defmodule Project1 do

    def main(args) do

        serveOrWork = "#{args}"

        if serveOrWork=~"." do  #argument contains IP address

            #IO.puts "Worker to be initiated"
            Worker.initateWorker()

        else        #argument contains k value hence intiate server

            {k, _} = Integer.parse(serveOrWork)

            server = spawn(fn ->
            Server.talktoworkers(k)
            end)

            Node.start :'server@192.168.0.100'
            Node.set_cookie :human
            :global.register_name(:server, server)
            :global.sync()
            Server.mineCoins(k)
            Process.sleep(:infinity)

        end

        
    end

end






