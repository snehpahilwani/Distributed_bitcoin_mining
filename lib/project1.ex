defmodule Project1 do

    def main(args) do

        serveOrWork = "#{args}"

        if serveOrWork=~"." do  #argument contains IP address

            #IO.puts "Worker to be initiated"
            Worker.initateWorker(serveOrWork)

        else        #argument contains k value hence intiate server

            {k, _} = Integer.parse(serveOrWork)

            server = spawn(fn ->
            Server.talktoworkers(k)
            end)

            serverlink = "server@"<>get_my_ip() 
            Node.start(String.to_atom(serverlink))

            Node.set_cookie :human
            :global.register_name(:server, server)
            :global.sync()
            Server.mineCoins(k)
            Process.sleep(:infinity)

        end

        
    end

    defp get_my_ip do
        {os, _} = :os.type
        {:ok, ifs} = :inet.getif()
        ips = for {ip, _, _} <- ifs, do: to_string(:inet.ntoa(ip))
        if Atom.to_string(os) == "unix" do
        hd(ips)
      else
        List.last(ips)
      end
    end

end






