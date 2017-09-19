defmodule Server do
    def randomstr(length \\ 15) do
        Enum.join(["spahilwani;",:crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)])
    end

    def hashfunction(str) do
        :crypto.hash(:sha256, str) |> Base.encode16 
    end

    # def genzero(k) do
    #     x =""
    #     for y<-1..k, do: x<>"0"
    # end
    def genzero(x,k) do
        for y<-1..k,
        do: x<> "0" 
    end

    def talktoworkers(k) do
        receive do
            #msg -> IO.puts "I got a message! #{inspect msg}"
            {:bitcoin, response} ->
                IO.puts "Bitcoin from worker : #{inspect response}"
            {:ready, client} ->
                IO.puts "Got new connection. Sending k"
                :global.sync()
                #:global.whereis_name(client) |> send(:k,k)
                send(:global.whereis_name(client), k)
                IO.puts client
                IO.inspect :global.whereis_name(client)
                #send(:global.whereis_name(:worker), k)


            # if msg == :ready do
            #     IO.puts "Got request from new worker. Sending k"
            #     IO.inspect Node.list
            #     # IO.puts :global.whereis_name(:worker)
            #     :global.sync()
            #     IO.puts :global.whereis_name(:worker)
            #     send(:global.whereis_name(:worker), k)
            #     IO.puts "sent"
            #     IO.puts k
            # else
            #     IO.puts "Bitcoin from worker : #{inspect msg}"
            # end

        end
        talktoworkers(k)
    end 
    


    def mineCoins(k) do
            #IO.puts "Num : #{max}"
            Enum.each(1..9, fn(_)->
                spawn(fn ->
                    Server.generatebitcoinsParallel(k)
                    end)
              end)
    end  

    def generatebitcoinsParallel(k) do
        newstr = randomstr()
        hashstr = hashfunction(newstr)
        if String.slice(hashstr,0,k) == Enum.join(genzero("",k)) do 
            IO.puts newstr <> "\t" <> hashstr
        end
        generatebitcoinsParallel(k)
    end


end

#IO.puts Server.genzero("",3)







# Node.start :'server@192.168.0.106' 
# Node.set_cookie :human
#IO_puts "Server up. Checking for worker."
#IO_puts Node.connect "worker@192.168.0.105"


# node 1
#Node.connect(:'worker@192.168.0.111')






