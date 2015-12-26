
# v 1.0

Class Hotel
{
    [string] $Name
    [int] $Price
    [int] $ID
    [int] $LastStays

    Hotel([string] $Name,[int] $Price, [int] $ID){
        $this.Name = $Name
        $this.Price = $Price
        $this.ID = $ID
    }

    [int] StayNights()
    {
        $roll = Get-Random -Minimum 1 -Maximum 7
        $this.LastStays = $roll
        return  $roll*$this.Price  
    }
}

Class Player
{
    [string] $Name
    [int] $Money
    [int] $Coordinate
    [int[]] $Hotels
    [int] $LastRoll
    [int] $LastPayment

    Player([string] $Name,[int] $Money,[int[]] $Hotels){
        $this.Name = $Name
        $this.Money = $Money
        $this.Hotels = $Hotels
        $this.Coordinate = 0
    }

    Move([int] $steps, [Player] $OtherPlayer)
    {
        if($this.Coordinate + $steps -le 29)
        {
            $this.Coordinate += $steps

            if($OtherPlayer.Coordinate -eq $this.Coordinate)
            {
                # Write-Warning "Plus 1 step"
                $this.Coordinate += 1

                if($this.Coordinate -gt 29)
                {
                    $this.Coordinate = ($this.Coordinate - 30)
                }

            }
        }
        else
        {
            $this.Coordinate = (($this.Coordinate + $steps) - 30)

            if($OtherPlayer.Coordinate -eq $this.Coordinate)
            {
                # Write-Warning "Plus 1 step"
                $this.Coordinate += 1

                if($this.Coordinate -gt 29)
                {
                    $this.Coordinate = ($this.Coordinate - 30)
                }
            }

            $this.Money += 2000
        }
    }

    [int] Roll()
    {    
        $roll = Get-Random -Minimum 1 -Maximum 7
        $this.LastRoll = $roll
        return $roll
    }

    pay ([int] $Amount, [Player] $Target)
    {
        if($this.Money - $Amount -ge 0)
        {
            $this.Money -= $Amount
            $Target.Money += $Amount
            $this.LastPayment = $Amount
        }
        else
        {
            $this.Money = 0
            Write-Warning "$($this.Name) has no money to pay!"
        }
    }
}

$HotelsPropList = (
    ('Reine',750,1),
    ('Artika',600,2),
    ('UptownTowers',1100,3),
    ('CoconutBeachClub',1000,4),
    ('AlWalid',400,5),
    ('ZebraLodge',500,6),
    ('DragonGate',400,7),
    ('ReefResort',600,8)
)

$PlayerPropList = (
    ('Sami',10000,(1,4,5,6,7)),
    ('Heini',20000,(2,3,8))
)

$map = (
    1,
    1,
    1,
    2,
    3,
    3,
    2,
    3,
    2,
    2,
    4,
    2,
    4,
    1,
    1,
    1,
    1,
    5,
    6,
    6,
    1,
    1,
    1,
    7,
    7,
    8,
    8,
    8,
    8,
    7
)

$hotels = foreach($h in $HotelsPropList) 
{
    New-Object Hotel -ArgumentList $h
}

$players = foreach($p in $PlayerPropList) 
{
    New-Object Player -ArgumentList $p
}


# Game loop, this represents one turn for all players and continue until someone run out of money
while($players[0].Money -gt 0 -and $players[1].Money -gt 0)
{

    # Go through players
    0..1 | % {
        
        $players[$_].LastRoll = 0

        # One players turn
        do
        {
            Write-Output "[$($players[$_].Name)] Turn. Money: [$($players[$_].Money) €]. Coordinate: [$($players[$_].coordinate)]"

            # Move, roll and pass the other player as argument to move method
            $players[$_].Move($players[$_].Roll(), $players[([math]::Abs($_ - 1))])

            Write-Output "[$($players[$_].Name)] Rolled [$($players[$_].LastRoll)]. New coordinate: [$($players[$_].coordinate)]. Entered: [$(($hotels | where ID -eq $map[$players[$_].Coordinate]).Name)]"

            if($map[$players[$_].Coordinate] -notin $players[$_].Hotels)
            {
                $players[$_].pay(($hotels | where ID -eq $map[$players[$_].Coordinate]).StayNights(),$players[([math]::Abs($_ - 1))])
                Write-Warning "[$($players[$_].Name)] Stayed [$(($hotels | where ID -eq $map[$players[$_].Coordinate]).LastStays)] nights. Payed [$($players[$_].LastPayment) €]. Money: [$($players[$_].Money) €]"
            }

        }while($players[$_].LastRoll -eq 6)
    }
}

