  function [ x_pro, P ] = Model_mix2( u,x1,x2,P1,P2)
  x_pro = x1*u(1) + x2*u(2);
  P = u(1)*(P1 + (x1 - x_pro)*((x1-x_pro)'))+...
            u(2)*(P2 + (x2-x_pro)*((x2-x_pro)'))
  end