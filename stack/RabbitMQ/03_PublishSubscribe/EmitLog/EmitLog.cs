using System;
using System.Text;
using RabbitMQ.Client;

// "publish/subsribe model"
// messages are delivered to multiple consumers
// messages are not transmitted directly between producers and consumers (via a queue)
// but are delivered via an 'exchange'
// exchanges simply recieve messages from consumers and send them to queues
// which queue, how it show be sent (or discarded) is the job of an exchange
// exchange types include direct, topic, headers, and fanout


class EmitLog
{
    public static void Main(string[] args)
    {
        var factory = new ConnectionFactory() { HostName = "localhost" };

        using(var connection = factory.CreateConnection())
        using(var channel = connection.CreateModel())
        {
            // declare the exchange type
            channel.ExchangeDeclare(exchange: "logs", type: ExchangeType.Fanout);

            // create message and encode
            var message = GetMessage(args);
            var body = Encoding.UTF8.GetBytes(message);

            // publish to exchange
            channel.BasicPublish(exchange: "logs",
                                 routingKey: "",
                                 basicProperties: null,
                                 body: body);
            Console.WriteLine("[x] Sent {0}", message);


        }

        Console.WriteLine("Press [enter] to exit");
        Console.ReadLine();
    }

    // create method for receiving message
    private static string GetMessage(string[] args)
    {
        return ((args.Length > 0) ? string.Join(" ", args) : "info: Hello World!");
    }
}



