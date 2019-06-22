        $sequence = 1, 2, 3, 4

        switch ( $sequence ) 
        {
            1 
            { 
                [void]$switch.MoveNext() 
                $switch.Current 
            }
            3 
            { 
                [void]$switch.MoveNext()
                $switch.Current 
            }
        }
